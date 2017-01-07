SourceInfo = require '../lib/source-info'
fs = require('fs')

describe "SourceInfo", ->
  editor = null
  sourceInfo = null

  withSetup = (opts) ->
    atom.project.getPaths = ->
      ["/projects/project_1", "/projects/project_2"]
    atom.project.relativize = (filePath) ->
      for folderPath in @getPaths()
        index = filePath.indexOf(folderPath)
        if index >= 0
          newPath = filePath.slice index + folderPath.length, filePath.length
          newPath = newPath.slice(1, newPath.length) if newPath[0] == '/'
          return newPath

    editor = {buffer: {file: {path: "/projects/project_2/test/foo_test.rb"}}}
    cursor = getBufferRow: -> 99
    editor.getLastCursor = -> cursor
    editor.lineTextForBufferRow = (line) -> ""
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn(editor)
    sourceInfo = new SourceInfo()

    if 'testFile' of opts
      editor.buffer.file.path = opts.testFile

    if 'projectPaths' of opts
      atom.project.getPaths = -> opts.projectPaths

    if 'currentLine' of opts
      cursor.getBufferRow = -> opts.currentLine - 1

    if 'fileContent' of opts
      lines = opts.fileContent.split("\n")
      editor.lineTextForBufferRow = (row) ->
        lines[row]

    if 'config' of opts
      for key, value of opts.config
        atom.config.set(key, value)

    if 'mockPaths' of opts
      spyOn(fs, 'existsSync').andCallFake (path) ->
        path in opts.mockPaths

  beforeEach ->
    editor = null
    sourceInfo = null

  describe "::projectPath", ->
    describe "with no testFile", ->
      it "is atom.project.getPaths()[0]", ->
        withSetup
          projectPaths: ['/projects/project_1', '/projects/project_2']
          testFile: null
        expect(sourceInfo.projectPath()).toBe("/projects/project_1")
    describe "with a testFile", ->
      it "is the path within atom.project.getPaths() that is an ancestor of the testFile path", ->
        withSetup
          projectPaths: ['/projects/project_1', '/projects/project_2']
          testFile: '/projects/project_2/foo/bar_test.rb'
        expect(sourceInfo.projectPath()).toBe("/projects/project_2")

  # Detect framework, by inspecting a combination of current file name,
  # project subdirectory names, current file content, and configuration value
  describe "::testFramework", ->
    describe "RSpec detection", ->
      it "detects RSpec based on configuration value set to 'rspec'", ->
        withSetup
          config: "ruby-test.specFramework": "rspec"
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_spec.rb'
          currentLine: 1
          fileContent: ''

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

      it "selects RSpec for spec file if spec_helper is required with require_relative", ->
        withSetup
          config: "ruby-test.specFramework": ""
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_spec.rb'
          currentLine: 2
          fileContent:
            """
            require_relative '../spec_helper'

            """
        expect(sourceInfo.testFramework()).toBe("rspec")

      it "selects RSpec for spec file if expect() is called", ->
        withSetup
          config: "ruby-test.specFramework": ""
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_spec.rb'
          currentLine: 5
          fileContent:
            """
            describe "something" do
              it "test something" do
                expect('foo').to eq 'foo'
              end
            end
            """
        expect(sourceInfo.testFramework()).toBe("rspec")

    describe "Minitest detection", ->
      it "is Minitest if filename matches _test.rb, and file contains specs", ->
        withSetup
          config: "ruby-test.specFramework": ""
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_test.rb'
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

      it "detects Minitest based on configuration value set to 'minitest'", ->
        withSetup
          config: "ruby-test.specFramework": "minitest"
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_spec.rb'
          currentLine: 1
          fileContent: ''

        expect(sourceInfo.testFramework()).toBe("minitest")

      it "is Minitest for a _test.rb file that contains Minitest::Test", ->
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

      it "when no test file is open, detects Minitest based on configuration value set to 'minitest'", ->
        withSetup
          config: "ruby-test.specFramework": "minitest"
          projectPaths: ['/home/user/project_1']
          testFile: null
          currentLine: null
          mockPaths: ['/home/user/project_1/spec']
          fileContent: ''

        expect(sourceInfo.testFramework()).toBe("minitest")

    describe "Test::Unit detection", ->
      it "assumes Test::Unit when the filename ends with _test.rb, has a method definition, and doesn't have a reference to Minitest", ->
        withSetup
          projectPaths: ['/home/user/project_1']
          testFile: '/home/user/project_1/bar/foo_test.rb'
          currentLine: 3
          fileContent:
            """
            class sometest < Whatever::Unit
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
          mockPaths: [
            '/home/user/project_1/spec',
            '/home/user/project_1/.rspec'
          ],
          fileContent:
            """
            """
        expect(sourceInfo.testFramework()).toBe("cucumber")

  # For when no test file is active
  # Detect project type, based on presence of a directory name matching a test framework
  describe "::projectType", ->
    it "correctly detects a test directory", ->
      withSetup
        projectPaths: ['/home/user/project_1']
        testFile: null
        mockPaths: ['/home/user/project_1/test']

      expect(sourceInfo.projectType()).toBe("test")

    it "correctly detecs a spec directory", ->
      withSetup
        projectPaths: ['/home/user/project_1']
        testFile: null
        mockPaths: ['/home/user/project_1/spec']

      expect(sourceInfo.projectType()).toBe("rspec")

    it "correctly detects a cucumber directory", ->
      withSetup
        projectPaths: ['/home/user/project_1']
        testFile: null
        mockPaths: ['/home/user/project_1/features']

      expect(sourceInfo.projectType()).toBe("cucumber")

  describe "::activeFile", ->
    it "is the project-relative path for the current file path", ->
      withSetup
        projectPaths: ['/projects/project_1', '/projects/project_2']
        testFile: '/projects/project_2/bar/foo_test.rb'
      expect(sourceInfo.activeFile()).toBe("bar/foo_test.rb")

  describe "::currentLine", ->
    it "is the cursor getBufferRow() plus 1", ->
      withSetup
        currentLine: 100
      expect(sourceInfo.currentLine()).toBe(100)

  describe "::minitestRegExp", ->
    it "correctly returns the matching regex for spec", ->
      withSetup
        projectPaths: ['/projects/project_1']
        testFile: '/projects/project_1/bar/foo_test.rb'
        currentLine: 6
        fileContent:
          """
          require 'minitest/spec'
          require 'minitest/autorun'

          describe "Addition" do
            it "adds" do
              (1 + 1).must_equal 2
            end
          end
          """
      expect(sourceInfo.minitestRegExp()).toBe("adds")

  describe "::minitestRegExp", ->
    it "correctly returns the matching regex for spec", ->
      sourceInfo = new SourceInfo()
      expect(sourceInfo.extractMinitestRegExp(" it \"test something\" do", "spec")).toBe("test something")

    it "correctly returns the matching regex for minitest unit", ->
      sourceInfo = new SourceInfo()
      expect(sourceInfo.extractMinitestRegExp(" def test_something", "unit")).toBe("test_something")

    it "should return empty string if no match", ->
      sourceInfo = new SourceInfo()
      expect(sourceInfo.extractMinitestRegExp("test something", "spec")).toBe("")
