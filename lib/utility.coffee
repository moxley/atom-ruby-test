module.exports =
class Utility
  saveFile: ->
    @editor().save() if @filePath()

  activePath: ->
    @filePath() or @treeViewSelectedPath()

  filePath: ->
    @editor() and
      @editor().buffer and
      @editor().buffer.file and
      @editor().buffer.file.path

  treeViewSelectedPath: ->
    @treeView().mainModule.treeView.selectedPath if @treeView()

  editor: ->
    atom.workspace.getActiveTextEditor()

  treeView: ->
    atom.packages.getActivePackage('tree-view')
