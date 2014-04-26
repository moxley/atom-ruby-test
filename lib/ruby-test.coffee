RubyTestView = require './ruby-test-view'

module.exports =
  configDefaults:
    testCommand: "rspec"

  rubyTestView: null

  activate: (state) ->
    atom.config.setDefaults "ruby-test",
      testCommand: "rspec"

    @rubyTestView = new RubyTestView(state.rubyTestViewState)

  deactivate: ->
    @rubyTestView.destroy()

  serialize: ->
    rubyTestViewState: @rubyTestView.serialize()
