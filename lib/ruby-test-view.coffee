_ = require 'underscore-plus'
{View} = require 'atom-space-pen-views'
TestRunner = require './test-runner'
ResizeHandle = require './resize-handle'
Utility = require './utility'
Convert = require 'ansi-to-html'

module.exports =
class RubyTestView extends View
  @content: ->
    @div class: "ruby-test inset-panel panel-bottom native-key-bindings", tabindex: -1, =>
      @div class: "ruby-test-resize-handle"
      @div class: "panel-heading", =>
        @span 'Running tests: '
        @span outlet: 'header'
        @div class: "heading-buttons pull-right inline-block", =>
          @div click: 'closePanel', class: "heading-close icon-x inline-block"
      @div class: "panel-body", =>
        @div class: 'ruby-test-spinner', 'Starting...'
        @pre "", outlet: 'results'

  initialize: (serializeState) ->
    atom.commands.add "atom-workspace", "ruby-test:toggle", => @toggle()
    atom.commands.add "atom-workspace", "ruby-test:test-file", => @testFile()
    atom.commands.add "atom-workspace", "ruby-test:test-single", => @testSingle()
    atom.commands.add "atom-workspace", "ruby-test:test-previous", => @testPrevious()
    atom.commands.add "atom-workspace", "ruby-test:test-all", => @testAll()
    atom.commands.add "atom-workspace", "ruby-test:cancel", => @cancelTest()
    new ResizeHandle(@)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @output = ''
    @detach()

  closePanel: ->
    if @hasParent()
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

  testAll: ->
    @runTest(testScope: "all")

  testPrevious: ->
    return unless @runner
    @saveFile()
    @newTestView()
    @runner.run()

  runTest: (overrideParams) ->
    @saveFile()
    @newTestView()
    params = _.extend({}, @testRunnerParams(), overrideParams || {})
    @runner = new TestRunner(params)
    @runner.run()
    @spinner.show()

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
      atom.workspace.addBottomPanel(item: @)
      @spinner = @find('.ruby-test-spinner')

  write: (str) =>
    @spinner.hide() if @spinner
    @output ||= ''
    convert = new Convert(escapeXML: true)
    converted = convert.toHtml(str)
    @output += converted
    @flush()

  flush: ->
    @results.html(@output)
    @results.parent().scrollTop(@results.innerHeight())

  cancelTest: ->
    @runner.cancel()
    @spinner?.hide()
    @write('\nTests canceled')

  saveFile: ->
    util = new Utility
    util.saveFile()
