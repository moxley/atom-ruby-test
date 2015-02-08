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
      path: "project/path"


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

  describe "::cwd", ->
    it "is atom.project.getPaths()[0]", ->
      setUpWithoutOpenFile()
      expect(sourceInfo.cwd()).toBe("fooPath")

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
      editor.getCursor = -> cursor
      expect(sourceInfo.currentLine()).toBe(100)

    describe "without editor", ->
      it "is null", ->
        setUpWithoutOpenFile()
        expect(sourceInfo.currentLine()).toBeNull()

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
