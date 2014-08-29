RubyTestView = require './ruby-test-view'

module.exports =
  configDefaults:
    testAllCommand: "ruby -I test test"
    testFileCommand: "ruby -I test {relative_path}"
    testSingleCommand: "ruby -I test {relative_path}:{line_number}"
    rspecAllCommand: "rspec --tty spec"
    rspecFileCommand: "rspec --tty {relative_path}"
    rspecSingleCommand: "rspec --tty {relative_path}:{line_number}"
    cucumberAllCommand: "cucumber features"
    cucumberFileCommand: "cucumber {relative_path}"
    cucumberSingleCommand: "cucumber {relative_path}:{line_number}"
    shell: "bash"

  rubyTestView: null

  activate: (state) ->
    atom.config.setDefaults "ruby-test", @configDefaults
    @rubyTestView = new RubyTestView(state.rubyTestViewState)

  deactivate: ->
    @rubyTestView.destroy()

  serialize: ->
    rubyTestViewState: @rubyTestView.serialize()
