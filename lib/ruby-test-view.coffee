{View} = require 'atom'
TestRunner = require './test-runner'

module.exports =
class RubyTestView extends View
  @content: ->
    @div class: "ruby-test inset-panel panel-bottom", =>
      @div class: "panel-heading", =>
        @span 'Running tests: '
        @span outlet: 'header'
      @div class: "panel-body padded results", =>
        @pre "", outlet: 'results'

  initialize: (serializeState) ->
    atom.workspaceView.command "ruby-test:toggle", => @toggle()
    atom.workspaceView.command "ruby-test:run", => @run()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @output = ''
    @detach()

  toggle: ->
    console.log "RubyTestView was toggled!"
    if @hasParent()
      @detach()
    else
      @showPanel()

  run: ->
    params = @testRunnerParams()
    @header.text(params.command())
    @output = ''
    @flush()
    @showPanel()
    runner = new TestRunner(params)
    runner.run()

  testRunnerParams: ->
    write: @write
    exit: @onTestRunEnd
    command: @testCommand

  cwd: ->
    atom.project.getPath()

  testCommand: =>
    runTestCmd = atom.config.
                      get("ruby-test.testCommand").
                      replace('{relative_path}', @activeFile())
    "cd #{@cwd()} && #{runTestCmd}"

  onTestRunEnd: =>
    null

  showPanel: ->
    atom.workspaceView.prependToBottom(@) unless @hasParent()

  write: (str) =>
    @output ||= ''
    @output += str
    @flush()

  flush: ->
    @results.text(@output)

  activeFile: ->
    atom.project.relativize(atom.workspace.getActiveEditor().buffer.file.path)
