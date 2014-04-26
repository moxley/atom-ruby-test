SourceInfo = require '../lib/source-info'

describe "SourceInfo", ->
  beforeEach ->
    project =
      getPath: ->
        "fooPath"
      relativize: (filePath) ->
        "fooDirectory/#{filePath}"
    atom.project = project
    @savedTestFileCommand = atom.config.get("ruby-test.testFileCommand")
    atom.config.set("ruby-test.testFileCommand", "fooCommand")
    @savedTestSingleCommand = atom.config.get("ruby-test.testFileCommand")
    atom.config.set("ruby-test.testSingleCommand", "fooSingleCommand")
    @editor =
      buffer:
        file:
          path:
            "fooFilePath"
    spyOn(atom.workspace, 'getActiveEditor').andReturn(@editor)
    @params = new SourceInfo()

  describe "::cwd", ->
    it "is atom.project.getPath()", ->
      expect(@params.cwd()).toBe("fooPath")

  describe "::testFileCommand", ->
    it "is the atom config for 'ruby-test.testFileCommand'", ->
      expect(@params.testFileCommand()).toBe("fooCommand")

  describe "::testSingleCommand", ->
    it "is the atom config for 'ruby-test.testSingleCommand'", ->
      expect(@params.testSingleCommand()).toBe("fooSingleCommand")

  describe "::activeFile", ->
    it "is the project-relative path for the current file path", ->
      expect(@params.activeFile()).toBe("fooDirectory/fooFilePath")

  describe "::currentLine", ->
    it "is the cursor screenRow() plus 1", ->
      cursor =
        getScreenRow: ->
          99
      @editor.getCursor = -> cursor
      expect(@params.currentLine()).toBe(100)

  afterEach ->
    delete atom.project
    atom.config.set("ruby-test.testFileCommand", @savedTestFileCommand)
    atom.config.set("ruby-test.testSingleCommand", @savedTestSingleCommand)
