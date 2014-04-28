{$} = require 'atom'

module.exports =
  class ResizeHandle
    constructor: (view) ->
      @view = view
      @view.on 'dblclick', '.ruby-test-resize-handle', @resizeToFitContent
      @view.on 'mousedown', '.ruby-test-resize-handle', @resizeStarted

    resizeToFitContent: =>
      @view.height(1)
      @view.height(Math.max(@view.outerHeight(), 40))

    resizeTreeView: (_arg) =>
      workspaceHeight = $('.workspace').height()
      statusBarHeight = $('.status-bar').height()
      @view.height(workspaceHeight - _arg.pageY - statusBarHeight)

    resizeStarted: =>
      console.log "resizeStarted"
      $(document.body).on 'mousemove', @resizeTreeView
      $(document.body).on 'mouseup', @resizeStopped

    resizeStopped: =>
      $(document.body).off('mousemove', @resizeTreeView)
      $(document.body).off('mouseup', @resizeStopped)
