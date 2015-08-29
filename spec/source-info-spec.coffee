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

  setUpWithOpenFile = ->
    setUpProjectPaths()
    setUpPackageConfig()
    setUpOpenFile()
    sourceInfo = new SourceInfo()

  setUpWithoutOpenFile = ->
    setUpProjectPaths()
    setUpPackageConfig()
    sourceInfo = new SourceInfo()

  beforeEach ->
    editor = null
    sourceInfo = null
    savedCommands = {}
    atom.project = null

  describe "::projectPath", ->
    it "is atom.project.getPaths()[0]", ->
      setUpWithoutOpenFile()
      expect(sourceInfo.projectPath()).toBe("fooPath")

  describe "::fileType", ->
    it "correctly detects a minitest file", ->
      setUpWithOpenFile()
      editor.lineTextForBufferRow = (line) ->
        " it \"test something\" do"
      expect(sourceInfo.fileType()).toBe("minitest")

  # Detect framework, by inspecting a combination of current file name,
  # project subdirectory names, current file content, and configuration value
  describe "::testFramework", ->
    setupRspecFile = ->
      projectPath = "#{__dirname}/fixtures/rspec_project"
      specFilePath = "#{projectPath}/spec/addition_spec.rb"

      sourceInfo = new SourceInfo()
      sourceInfo.activeFile = -> specFilePath
      sourceInfo.projectPath = -> projectPath

    it "detects RSpec based on configuration value set to 'rspec'", ->
      setupRspecFile()
      atom.config.set("ruby-test.specFramework", "rspec")

      expect(sourceInfo.testFramework()).toBe("rspec")

    it "detects Minitest based on configuration value set to 'miniteset'", ->
      setupRspecFile()
      atom.config.set("ruby-test.specFramework", "minitest")
      expect(sourceInfo.testFramework()).toBe("minitest")

    it "selects RSpec for spec file by default", ->
      atom.config.set("ruby-test.specFramework", "")
      setupRspecFile()
      expect(sourceInfo.testFramework()).toBe("rspec")

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
      setUpWithOpenFile()
      expect(sourceInfo.testFileCommand()).toBe("foo-testFileCommand")

    it "is the atom config for 'ruby-test.rspecFileCommand' for an rspec file", ->
      setUpWithOpenFile()
      editor.buffer.file.path = 'foo_spec.rb'
      expect(sourceInfo.testFileCommand()).toBe("foo-rspecFileCommand")

  describe "::testSingleCommand", ->
    it "is the atom config for 'ruby-test.testSingleCommand'", ->
      setUpWithOpenFile()
      expect(sourceInfo.testSingleCommand()).toBe("foo-testSingleCommand")

  describe "::activeFile", ->
    it "is the project-relative path for the current file path", ->
      setUpWithOpenFile()
      expect(sourceInfo.activeFile()).toBe("fooDirectory/foo_test.rb")

  describe "::currentLine", ->
    it "is the cursor getBufferRow() plus 1", ->
      setUpWithOpenFile()
      cursor =
        getBufferRow: ->
          99
      editor.getLastCursor = -> cursor
      expect(sourceInfo.currentLine()).toBe(100)

    describe "without editor", ->
      it "is null", ->
        setUpWithoutOpenFile()
        expect(sourceInfo.currentLine()).toBeNull()

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

  describe "::isMiniTest", ->
    it "correctly returns true if it is minitest spec file", ->
      setUpWithOpenFile()
      cursor =
        getBufferRow: ->
          99
      editor.lineTextForBufferRow = (line) ->
        if line == 99
          " it \"test something\" do"
      expect(sourceInfo.isMiniTest("")).toBe(true)

    it "correctly returns true if it is a minitest unit file", ->
      setUpWithOpenFile()
      cursor =
        getBufferRow: ->
          10
      editor.getLastCursor = -> cursor
      editor.lineTextForBufferRow = (line) ->
        if line == 10
          " def something"
        else if line == 5
          "class sometest < Minitest::Test"
      expect(sourceInfo.isMiniTest("")).toBe(true)

    it "correctly returns false if it is a rspec file", ->
      setUpWithOpenFile()
      cursor =
        getBufferRow: ->
          10
      editor.getLastCursor = -> cursor
      editor.lineTextForBufferRow = (line) ->
        if line == 10
          " it \"test something\" do"
        else if line == 5
          "require \"spec_helper\""
      expect(sourceInfo.isMiniTest("")).toBe(false)

    it "correctly returns false if it is a unit test file", ->
      setUpWithOpenFile()
      cursor =
        getBufferRow: ->
          10
      editor.getLastCursor = -> cursor
      editor.lineTextForBufferRow = (line) ->
        if line == 10
          " def something"
        else if line == 5
          "class sometest < Unit::Test"
      expect(sourceInfo.isMiniTest("")).toBe(false)

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
