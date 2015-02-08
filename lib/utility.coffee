module.exports =
class Utility
  saveFile: ->
    @editor().save() if @filePath()

  filePath: ->
    @editor() and
      @editor().buffer and
      @editor().buffer.file and
      @editor().buffer.file.path

  editor: ->
    atom.workspace.getActiveTextEditor()
