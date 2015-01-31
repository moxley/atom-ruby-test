{$} = require 'atom-space-pen-views'

module.exports =
  class ResizeHandle
    constructor: (view) ->
      @view = view
      @view.on 'dblclick', '.ruby-test-resize-handle', @resizeToFitContent
      @view.on 'mousedown', '.ruby-test-resize-handle', @resizeStarted
      @panelBody = @view.find('.panel-body')
      @resultsEl = @view.results

    resizeToFitContent: =>
      @panelBody.height(1)
      @panelBody.height(Math.max(@resultsEl.outerHeight(), 40))

    resizeTreeView: (_arg) =>
      workspaceHeight = $('.workspace').outerHeight()
      statusBarHeight = $('.status-bar').outerHeight()
      testBarHeight = $('.ruby-test .panel-heading').outerHeight()
      @panelBody.height(workspaceHeight - _arg.pageY - statusBarHeight - testBarHeight - 28)

    resizeStarted: =>
      $(document.body).on 'mousemove', @resizeTreeView
      $(document.body).on 'mouseup', @resizeStopped

    resizeStopped: =>
      $(document.body).off('mousemove', @resizeTreeView)
      $(document.body).off('mouseup', @resizeStopped)
