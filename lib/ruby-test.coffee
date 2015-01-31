RubyTestView = require './ruby-test-view'

module.exports =
  config:
    testAllCommand:
      type: 'string'
      default: "ruby -I test test"
    testFileCommand:
      type: 'string'
      default: "ruby -I test {relative_path}"
    testSingleCommand:
      type: 'string'
      default: "ruby -I test {relative_path}:{line_number}"
    rspecAllCommand:
      type: 'string',
      default: "rspec --tty spec"
    rspecFileCommand:
      type: 'string',
      default: "rspec --tty {relative_path}"
    rspecSingleCommand:
      type: 'string',
      default: "rspec --tty {relative_path}:{line_number}"
    cucumberAllCommand:
      type: 'string',
      default: "cucumber --color features"
    cucumberFileCommand:
      type: 'string',
      default: "cucumber --color {relative_path}"
    cucumberSingleCommand:
      type: 'string',
      default: "cucumber --color {relative_path}:{line_number}"
    shell:
      type: 'string',
      default: "bash"

  configDefaults:
    testAllCommand: "ruby -I test test"
    testFileCommand: "ruby -I test {relative_path}"
    testSingleCommand: "ruby -I test {relative_path}:{line_number}"
    rspecAllCommand: "rspec --tty spec"
    rspecFileCommand: "rspec --tty {relative_path}"
    rspecSingleCommand: "rspec --tty {relative_path}:{line_number}"
    cucumberAllCommand: "cucumber --color features"
    cucumberFileCommand: "cucumber --color {relative_path}"
    cucumberSingleCommand: "cucumber --color {relative_path}:{line_number}"
    shell: "bash"

  rubyTestView: null

  activate: (state) ->
    @rubyTestView = new RubyTestView(state.rubyTestViewState)

  deactivate: ->
    @rubyTestView.destroy()

  serialize: ->
    rubyTestViewState: @rubyTestView.serialize()
