_ = require 'underscore-plus'
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
        @div class: 'ruby-test-spinner', 'Starting...'
        @pre "", outlet: 'results'

  initialize: (serializeState) ->
    atom.workspaceView.command "ruby-test:toggle", => @toggle()
    atom.workspaceView.command "ruby-test:test-file", => @testFile()
    atom.workspaceView.command "ruby-test:test-single", => @testSingle()
    atom.workspaceView.command "ruby-test:test-previous", => @testPrevious()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @output = ''
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      @showPanel()
      unless @runner
        @spinner.hide()
        @setTestInfo("No tests running")

  testFile: ->
    @runTest()

  testSingle: ->
    @runTest(testScope: "single")

  testPrevious: ->
    return unless @runner
    @newTestView()
    @runner.run()

  runTest: (overrideParams) ->
    @newTestView()
    params = _.extend({}, @testRunnerParams(), overrideParams || {})
    @runner = new TestRunner(params)
    @runner.run()

  newTestView: ->
    @output = ''
    @flush()
    @showPanel()

  testRunnerParams: ->
    write: @write
    exit: @onTestRunEnd
    setTestInfo: @setTestInfo

  setTestInfo: (infoStr) =>
    @header.text(infoStr)

  onTestRunEnd: =>
    null

  showPanel: ->
    unless @hasParent()
      atom.workspaceView.prependToBottom(@)
      @spinner = @find('.ruby-test-spinner')

  write: (str) =>
    @spinner.hide()
    @output ||= ''
    @output += str
    @flush()

  flush: ->
    @results.text(@output)
