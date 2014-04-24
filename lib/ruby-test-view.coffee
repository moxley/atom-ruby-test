{View} = require 'atom'

module.exports =
class RubyTestView extends View
  @content: ->
    @div class: "shell-runner inset-panel panel-bottom", =>
      @div class: "panel-heading", =>
        @span 'Running command: '
        @span outlet: 'header'
      @div class: "panel-body padded results", =>
        @pre "FOOOO", outlet: 'results'

  initialize: (serializeState) ->
    atom.workspaceView.command "ruby-test:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "RubyTestView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.prependToBottom(this)
