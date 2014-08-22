SourceInfo = require '../lib/source-info'

describe "SourceInfo", ->
  beforeEach ->
    project =
      getPath: ->
        "fooPath"
      relativize: (filePath) ->
        "fooDirectory/#{filePath}"
    atom.project = project
    @frameworks = ['test', 'rspec', 'cucumber']
    @savedCommands = {}
    for framework in @frameworks
      @savedCommands["#{framework}-file"] = atom.config.get("ruby-test.#{framework}FileCommand")
      atom.config.set("ruby-test.#{framework}FileCommand", "foo-#{framework}FileCommand")
      @savedCommands["#{framework}-single"] = atom.config.get("ruby-test.#{framework}SingleCommand")
      atom.config.set("ruby-test.#{framework}SingleCommand", "foo-#{framework}SingleCommand")
    @editor =
      buffer:
        file:
          path:
            "foo_test.rb"
    spyOn(atom.workspace, 'getActiveEditor').andReturn(@editor)
    @params = new SourceInfo()

  describe "::cwd", ->
    it "is atom.project.getPath()", ->
      expect(@params.cwd()).toBe("fooPath")

  describe "::testFileCommand", ->
    it "is the atom config for 'ruby-test.testFileCommand'", ->
      expect(@params.testFileCommand()).toBe("foo-testFileCommand")

    it "is the atom config for 'ruby-test.rspecFileCommand' for an rspec file", ->
      @editor.buffer.file.path = 'foo_spec.rb'
      expect(@params.testFileCommand()).toBe("foo-rspecFileCommand")

  describe "::testSingleCommand", ->
    it "is the atom config for 'ruby-test.testSingleCommand'", ->
      expect(@params.testSingleCommand()).toBe("foo-testSingleCommand")

  describe "::activeFile", ->
    it "is the project-relative path for the current file path", ->
      expect(@params.activeFile()).toBe("fooDirectory/foo_test.rb")

  describe "::currentLine", ->
    it "is the cursor getBufferRow() plus 1", ->
      cursor =
        getBufferRow: ->
          99
      @editor.getCursor = -> cursor
      expect(@params.currentLine()).toBe(100)

  describe "::currentShell", ->
    it "when ruby-test.shell is null", ->
      expect(@params.currentShell).toBe('bash')

  afterEach ->
    delete atom.project
    for framework in @frameworks
      atom.config.set("ruby-test.#{framework}FileCommand", @savedCommands["#{framework}-file"])
      atom.config.set("ruby-test.#{framework}SingleCommand", @savedCommands["#{framework}-single"])
