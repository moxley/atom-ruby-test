module.exports =
  class SourceInfo
    cwd: ->
      atom.project.getPath()

    testFileCommand: ->
      atom.config.get("ruby-test.testFileCommand")

    testSingleCommand: ->
      atom.config.get("ruby-test.testSingleCommand")

    activeFile: ->
      atom.project.relativize(atom.workspace.getActiveEditor().buffer.file.path)

    currentLine: ->
      editor = atom.workspace.getActiveEditor()
      cursor = editor.getCursor()
      cursor.getScreenRow() + 1
