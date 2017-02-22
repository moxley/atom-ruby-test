{$$} = require 'atom-space-pen-views'
RubyTestView = require '../lib/ruby-test-view'
TestRunner = require '../lib/test-runner'

describe "RubyTestView", ->
  activeEditor = null
  testRunnerInitializeParams = null
  view = null
  fileOpened = false
  terminalMock = null

  beforeEach ->
    mockGetTerminalViews = [ { terminal: closeBtn: { click: -> } } ]
    @terminalMock = {
      run: (commands) ->
      getTerminalViews: () =>
        mockGetTerminalViews
    }
    view = new RubyTestView({}, @terminalMock)

  spyOnTestRunnerInitialize = ->
    spyOn(activeEditor, 'save')
    spyOn(TestRunner.prototype, 'initialize').andCallFake (params) ->
      testRunnerInitializeParams = params
    spyOn(TestRunner.prototype, 'run').andReturn(null)

  validateTestRunnerInitialize = ->
    expect(testRunnerInitializeParams).toBeDefined()
    expect(testRunnerInitializeParams).not.toBe(null)
    expect(testRunnerInitializeParams.write).toEqual(view.write)

  spyOnTestRunnerRun = ->
    if activeEditor?
      spyOn(activeEditor, 'save')
    spyOn(TestRunner.prototype, 'initialize').andCallThrough()
    spyOn(TestRunner.prototype, 'run').andCallThrough()
    spyOn(TestRunner.prototype, 'command').andReturn 'fooTestCommand'

  validateTestRunnerRun = ->
    expect(TestRunner.prototype.initialize).toHaveBeenCalled()
    expect(TestRunner.prototype.run).toHaveBeenCalledWith()
    expect(activeEditor.save).toHaveBeenCalled()

  setUpActiveEditor = ->
    atom.workspace.open('/tmp/text.txt').then (editor) ->
      activeEditor = editor
      fileOpened = true
    waitsFor -> fileOpened is true

  describe "with open editor", ->
    beforeEach ->
      fileOpened = false
      testRunnerInitializeParams = null
      activeEditor = null
      setUpActiveEditor()

    describe "::testAll", ->
      it "instantiates TestRunner with specific arguments", ->
        spyOnTestRunnerInitialize()

        view.testAll()

        validateTestRunnerInitialize()
        expect(testRunnerInitializeParams.testScope).toEqual('all')

      it "instantiates TestRunner and calls ::run on it", ->
        spyOnTestRunnerRun()

        view.testAll()

        validateTestRunnerRun()

    describe "::testFile", ->
      it "instantiates TestRunner with specific arguments", ->
        spyOnTestRunnerInitialize()

        view.testFile()

        validateTestRunnerInitialize()
        expect(testRunnerInitializeParams.testScope).toEqual('file')

      it "calls ::run on the TestRunner instance", ->
        spyOnTestRunnerRun()
        view.testFile()

        validateTestRunnerRun()

    describe "::testSingle", ->
      it "instantiates TestRunner with specific arguments", ->
        spyOnTestRunnerInitialize()

        view.testSingle()

        validateTestRunnerInitialize()
        expect(testRunnerInitializeParams.testScope).toEqual('single')

      it "instantiates TestRunner and calls ::run on it", ->
        spyOnTestRunnerRun()

        view.testSingle()

        validateTestRunnerRun()

    describe "::testPrevious", ->
      it "intantiates TestRunner and calls ::run on it with specific arguments", ->
        spyOn(activeEditor, 'save')

        previousRunner = new TestRunner({ scope: 'file' }, @terminalMock)
        previousRunner.command = -> "foo"
        view.runner = previousRunner
        view.testPrevious()

        expect(view.runner).toBe(previousRunner)
        expect(activeEditor.save).toHaveBeenCalled()

  describe "without open editor", ->
    beforeEach ->
      fileOpened = false
      testRunnerInitializeParams = null

    # Reproduce https://github.com/moxley/atom-ruby-test/issues/33:
    # "Uncaught TypeError: Cannot read property 'save' of undefined"
    describe "::testAll", ->
      it "instantiates TestRunner and calls ::run on it", ->
        spyOnTestRunnerRun()

        view.testAll()

        expect(TestRunner.prototype.initialize).toHaveBeenCalled()
        expect(TestRunner.prototype.run).toHaveBeenCalledWith()
