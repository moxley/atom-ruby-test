RubyTestView = require './ruby-test-view'

module.exports =
  configDefaults:
    testFileCommand: "rspec {relative_path}"

  rubyTestView: null

  activate: (state) ->
    atom.config.setDefaults "ruby-test",
      testFileCommand: "rspec {relative_path}"

    @rubyTestView = new RubyTestView(state.rubyTestViewState)

  deactivate: ->
    @rubyTestView.destroy()

  serialize: ->
    rubyTestViewState: @rubyTestView.serialize()
