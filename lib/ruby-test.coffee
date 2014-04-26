RubyTestView = require './ruby-test-view'

module.exports =
  configDefaults:
    testFileCommand: "rspec {relative_path}"
    testSingleCommand: "rspec {relative_path}:{line_number}"

  rubyTestView: null

  activate: (state) ->
    @rubyTestView = new RubyTestView(state.rubyTestViewState)

  deactivate: ->
    @rubyTestView.destroy()

  serialize: ->
    rubyTestViewState: @rubyTestView.serialize()
