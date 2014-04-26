module.exports =
  class TestParams
    cwd: ->
      atom.project.getPath()

    testFileCommand: ->
      atom.config.get("ruby-test.testFileCommand")

    activeFile: ->
      atom.project.relativize(atom.workspace.getActiveEditor().buffer.file.path)
