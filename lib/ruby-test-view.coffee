{View} = require 'atom'

module.exports =
class RubyTestView extends View
  @content: ->
    @div class: 'ruby-test overlay from-top', =>
      @div "The RubyTest package is Alive! It's ALIVE!", class: "message"

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
      atom.workspaceView.append(this)
