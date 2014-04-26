module.exports =
  class TestParams
    cwd: =>
      atom.project.getPath()

    command: =>
      atom.config.get("ruby-test.testCommand")

    activeFile: ->
      atom.project.relativize(atom.workspace.getActiveEditor().buffer.file.path)
