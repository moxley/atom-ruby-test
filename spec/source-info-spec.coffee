SourceInfo = require '../lib/source-info'
fs = require('fs')

describe "SourceInfo", ->
  frameworks = ['test', 'rspec', 'cucumber']
  savedCommands = {}
  editor = null
  sourceInfo = null

  setUpProjectPaths = ->
    atom.project =
      getPaths: ->
        ["fooPath"]
      relativize: (filePath) ->
        "fooDirectory/#{filePath}"

  setUpPackageConfig = ->
    savedCommands = {}
    for framework in frameworks
      savedCommands["#{framework}-all"] = atom.config.get("ruby-test.#{framework}AllCommand")
      atom.config.set("ruby-test.#{framework}AllCommand", "foo-#{framework}AllCommand")
      savedCommands["#{framework}-file"] = atom.config.get("ruby-test.#{framework}FileCommand")
      atom.config.set("ruby-test.#{framework}FileCommand", "foo-#{framework}FileCommand")
      savedCommands["#{framework}-single"] = atom.config.get("ruby-test.#{framework}SingleCommand")
      atom.config.set("ruby-test.#{framework}SingleCommand", "foo-#{framework}SingleCommand")


  setUpOpenFile = ->
    editor = {buffer: {file: {path: "foo_test.rb"}}}
    cursor =
      getBufferRow: ->
        99
    editor.getLastCursor = -> cursor
    editor.lineTextForBufferRow = (line) ->
      ""
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn(editor)

  setUpWithoutOpenFile = ->
    setUpProjectPaths()
    setUpPackageConfig()
    sourceInfo = new SourceInfo()

  withSetup = (opts) ->
    atom.project =
      getPaths: ->
        ["project_1"]
      relativize: (filePath) ->
        for path in @getPaths()
          index = filePath.indexOf(path)
          if index >= 0
            newPath = filePath.slice index + path.length, filePath.length
            newPath = newPath.slice(1, newPath.length) if newPath[0] == '/'
            return newPath

    editor = {buffer: {file: {path: "foo_test.rb"}}}
    cursor =
      getBufferRow: ->
        99
    editor.getLastCursor = -> cursor
    editor.lineTextForBufferRow = (line) ->
      ""
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn(editor)
    sourceInfo = new SourceInfo()

    if opts.testFile
      editor.buffer.file.path = opts.testFile

    if opts.projectPaths
      atom.project.getPaths = -> opts.projectPaths

    if opts.currentLine
      cursor.getBufferRow = -> opts.currentLine - 1

    if opts.fileContent
      lines = opts.fileContent.split("\n")
      editor.lineTextForBufferRow = (row) ->
        lines[row]

    if opts.config
      for key, value of opts.config
        atom.config.set(key, value)

  beforeEach ->
    editor = null
    sourceInfo = null
    savedCommands = {}
    atom.project = null

  describe "::projectPath", ->
    it "is atom.project.getPaths()[0]", ->
      setUpWithoutOpenFile()
      expect(sourceInfo.projectPath()).toBe("fooPath")

  # Detect framework, by inspecting a combination of current file name,
  # project subdirectory names, current file content, and configuration value
  describe "::testFramework", ->
    describe "RSpec detection", ->
      it "detects RSpec based on configuration value set to 'rspec'", ->
        withSetup
          config: "ruby-test.specFramework": "rspec"
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_spec.rb'
          currentLine: 3
          fileContent:
            """
            describe "something" do
              it "test something" do
                expect('foo').to eq 'foo'
              end
            end
            """

        expect(sourceInfo.testFramework()).toBe("rspec")

      it "selects RSpec for spec file if spec_helper is required", ->
        withSetup
          config: "ruby-test.specFramework": ""
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_spec.rb'
          currentLine: 5
          fileContent:
            """
            require 'spec_helper'

            describe "something" do
              it "test something" do
                expect('foo').to eq 'foo'
              end
            end
            """
        expect(sourceInfo.testFramework()).toBe("rspec")

    describe "Minitest detection", ->
      it "correctly returns true if filename matches _test.rb, and file contains specs", ->
        withSetup
          config: "ruby-test.specFramework": ""
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_test.rb'
          currentLine: 10
          fileContent:
            """
            describe "something" do
              it "test something" do
                1.must_equal 1
              end
            end
            """
        expect(sourceInfo.testFramework()).toBe("minitest")

      it "detects Minitest based on configuration value set to 'minitest'", ->
        withSetup
          config: "ruby-test.specFramework": "minitest"
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_spec.rb'
          currentLine: 3
          fileContent:
            """
            describe "something" do
              it "test something" do
                1.must_equal 1
              end
            end
            """

        expect(sourceInfo.testFramework()).toBe("minitest")

      it "correctly returns true if it is a minitest unit file", ->
        withSetup
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_test.rb'
          currentLine: 3
          fileContent:
            """
            class sometest < Minitest::Test
              def something
                assert_equal 1, 1
              end
            end
            """
        expect(sourceInfo.testFramework()).toBe("minitest")

    describe "TestUnit detection", ->
      it "correctly detects TestUnit file", ->
        withSetup
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_test.rb'
          currentLine: 3
          fileContent:
            """
            class sometest < Unit::Test
              def something
                assert_equal 1, 1
              end
            end
            """
        expect(sourceInfo.testFramework()).toBe("test")

    describe "Cucumber detection", ->
      it "correctly detects Cucumber file", ->
        withSetup
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/foo/foo.feature'
          currentLine: 1
          fileContent:
            """
            """
        expect(sourceInfo.testFramework()).toBe("cucumber")

  # Detect project type, based on presence of a directory name matching a test framework
  describe "::projectType", ->
    it "correctly detects a test directory", ->
      spyOn(fs, 'existsSync').andCallFake (filePath) ->
        filePath.match(/fooPath\/test$/)

      setUpWithoutOpenFile()
      expect(sourceInfo.projectType()).toBe("test")

    it "correctly detecs a spec directory", ->
      spyOn(fs, 'existsSync').andCallFake (filePath) ->
        filePath.match(/fooPath\/spec$/)

      setUpWithoutOpenFile()
      expect(sourceInfo.projectType()).toBe("rspec")

    it "correctly detects a cucumber directory", ->
      spyOn(fs, 'existsSync').andCallFake (filePath) ->
        filePath.match(/fooPath\/feature$/)

      setUpWithoutOpenFile()
      expect(sourceInfo.projectType()).toBe("cucumber")

  describe "::testAllCommand", ->
    it "is the atom config for 'ruby-test.testAllCommand'", ->
      # Simulate a project having a 'test' directory
      spyOn(fs, 'existsSync').andCallFake (filePath) ->
        filePath.match(/test$/)

      setUpWithoutOpenFile()
      expect(sourceInfo.testAllCommand()).toBe("foo-testAllCommand")

  describe "::rspecAllCommand", ->
    it "is the atom config for 'ruby-test.rspecAllCommand'", ->
      # Simulate a project having a 'spec' directory
      spyOn(fs, 'existsSync').andCallFake (filePath) ->
        filePath.match(/spec$/)

      setUpWithoutOpenFile()
      expect(sourceInfo.testAllCommand()).toBe("foo-rspecAllCommand")

  describe "::testFileCommand", ->
    it "is the atom config for 'ruby-test.testFileCommand'", ->
      withSetup
        config:
          "ruby-test.specFramework": "rspec"
          "ruby-test.rspecFileCommand": "my_rspec --tty {relative_path}"
        projectPaths: ['/home/user/project_1']
        testFile: '/home/user/project_1/bar/foo_spec.rb'
        currentLine: 1
        fileContent: ''

      expect(sourceInfo.testFileCommand()).toBe("my_rspec --tty {relative_path}")

  describe "::testSingleCommand", ->
    it "is the atom config for 'ruby-test.testSingleCommand'", ->
      withSetup
        config:
          "ruby-test.specFramework": "rspec"
          "ruby-test.rspecSingleCommand": "my_rspec --tty {relative_path}:{line_number}"
        projectPaths: ['/home/user/project_1']
        testFile: '/home/user/project_1/bar/foo_spec.rb'
        currentLine: 1
        fileContent: ''
      expect(sourceInfo.testSingleCommand()).toBe("my_rspec --tty {relative_path}:{line_number}")

  describe "::activeFile", ->
    it "is the project-relative path for the current file path", ->
      withSetup
        projectPaths: ['/home/user/project_1']
        testFile: '/home/user/project_1/bar/foo_test.rb'
      expect(sourceInfo.activeFile()).toBe("bar/foo_test.rb")

  describe "::currentLine", ->
    it "is the cursor getBufferRow() plus 1", ->
      withSetup
        currentLine: 100
      expect(sourceInfo.currentLine()).toBe(100)

  describe "::extractMinitestRegExp", ->
    it "correctly returns the matching regex for spec", ->
      setUpWithoutOpenFile()
      expect(sourceInfo.extractMinitestRegExp(" it \"test something\" do", "spec")).toBe("test something")

    it "correctly returns the matching regex for minitest unit", ->
      setUpWithoutOpenFile()
      expect(sourceInfo.extractMinitestRegExp(" def test_something", "unit")).toBe("test_something")

    it "should return empty string if no match", ->
      setUpWithoutOpenFile()
      expect(sourceInfo.extractMinitestRegExp("test something", "spec")).toBe("")

  describe "::currentShell", ->
    it "when ruby-test.shell is null", ->
      setUpWithoutOpenFile()
      expect(sourceInfo.currentShell()).toBe('bash')

  afterEach ->
    delete atom.project
    for framework in frameworks
      atom.config.set("ruby-test.#{framework}AllCommand", savedCommands["#{framework}-all"])
      atom.config.set("ruby-test.#{framework}FileCommand", savedCommands["#{framework}-file"])
      atom.config.set("ruby-test.#{framework}SingleCommand", savedCommands["#{framework}-single"])
