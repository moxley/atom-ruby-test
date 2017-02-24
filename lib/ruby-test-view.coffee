{$,View} = require 'atom-space-pen-views'
TestRunner = require './test-runner'
Utility = require './utility'
SourceInfo = require './source-info'
Convert = require 'ansi-to-html'

module.exports =
class RubyTestView extends View
  @content: ->
    @div class: "ruby-test inset-panel panel-bottom native-key-bindings", tabindex: -1, =>

  initialize: (serializeState, terminal) ->
    @terminal = terminal;
    sourceInfo = new SourceInfo()
    atom.commands.add "atom-workspace", "ruby-test:toggle", => @toggle()
    atom.commands.add "atom-workspace", "ruby-test:test-file", => @testFile()
    atom.commands.add "atom-workspace", "ruby-test:test-single", => @testSingle()
    atom.commands.add "atom-workspace", "ruby-test:test-previous", => @testPrevious()
    atom.commands.add "atom-workspace", "ruby-test:test-all", => @testAll()
    atom.commands.add "atom-workspace", "ruby-test:cancel", => @cancelTest()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @output = ''
    @detach()

  closePanel: ->
    if @hasParent()
      @detach()

  currentEditor: ->
    atom.views.getView(atom.workspace.getActiveTextEditor())

  toggle: ->
    atom.commands.dispatch(@currentEditor(), 'platformio-ide-terminal:toggle')

  testFile: ->
    @runTest(testScope: "file")

  testSingle: ->
    @runTest(testScope: "single")

  testAll: ->
    @runTest(testScope: "all")

  testPrevious: ->
    return unless @runner
    @saveFile()
    @runner.run()

  runTest: (params) ->
    @saveFile()
    @runner = new TestRunner(params, @terminal)
    @runner.run()

  onTestRunEnd: =>
    null

  showPanel: ->
    unless @hasParent()
      atom.workspace.addBottomPanel(item: @)
      @spinner = @find('.ruby-test-spinner')

  cancelTest: ->
    atom.commands.dispatch(@currentEditor(), 'platformio-ide-terminal:close')

  saveFile: ->
    util = new Utility
    util.saveFile()
