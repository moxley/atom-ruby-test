RubyTestView = require './ruby-test-view'

module.exports =
  configDefaults:
    testFileCommand: "ruby -I test {relative_path}"
    testSingleCommand: "ruby -I test {relative_path}:{line_number}"
    rspecFileCommand: "rspec {relative_path}"
    rspecSingleCommand: "rspec {relative_path}:{line_number}"
    cucumberFileCommand: "cucumber {relative_path}"
    cucumberSingleCommand: "cucumber {relative_path}:{line_number}"

  rubyTestView: null

  activate: (state) ->
    @rubyTestView = new RubyTestView(state.rubyTestViewState)

  deactivate: ->
    @rubyTestView.destroy()

  serialize: ->
    rubyTestViewState: @rubyTestView.serialize()
