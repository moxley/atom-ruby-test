_ = require 'underscore-plus'
{$$} = require 'atom-space-pen-views'
RubyTestView = require '../lib/ruby-test-view'
TestRunner = require '../lib/test-runner'

describe "RubyTestView", ->
  activeEditor = null
  testRunnerInitializeParams = null
  view = null
  fileOpened = false

  spyOnTestRunnerInitialize = ->
    spyOn(activeEditor, 'save')
    spyOn(TestRunner.prototype, 'initialize').andCallFake (params) ->
      testRunnerInitializeParams = params
    spyOn(TestRunner.prototype, 'run').andReturn(null)

  validateTestRunnerInitialize = ->
    expect(testRunnerInitializeParams).toBeDefined()
    expect(testRunnerInitializeParams).not.toBe(null)
    expect(testRunnerInitializeParams.write).toEqual(view.write)
    expect(testRunnerInitializeParams.exit).toEqual(view.onTestRunEnd)
    expect(testRunnerInitializeParams.setTestInfo).toEqual(view.setTestInfo)

  spyOnTestRunnerRun = ->
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
      view = null
      activeEditor = null
      setUpActiveEditor()

    describe "::testAll", ->
      it "instantiates TestRunner with specific arguments", ->
        spyOnTestRunnerInitialize()

        view = new RubyTestView()
        view.testAll()

        validateTestRunnerInitialize()
        expect(testRunnerInitializeParams.testScope).toEqual('all')

      it "instantiates TestRunner and calls ::run on it", ->
        spyOnTestRunnerRun()

        view = new RubyTestView()
        view.testAll()

        validateTestRunnerRun()

    describe "::testFile", ->
      it "instantiates TestRunner with specific arguments", ->
        spyOnTestRunnerInitialize()

        view = new RubyTestView()
        view.testFile()

        validateTestRunnerInitialize()
        expect(testRunnerInitializeParams.testScope).not.toBeDefined()

      it "calls ::run on the TestRunner instance", ->
        spyOnTestRunnerRun()

        view = new RubyTestView()
        spyOn(view, 'setTestInfo').andCallThrough()
        view.testFile()

        validateTestRunnerRun()
        expect(view.setTestInfo).toHaveBeenCalled()

    describe "::testSingle", ->
      it "instantiates TestRunner with specific arguments", ->
        spyOnTestRunnerInitialize()

        view = new RubyTestView()
        view.testSingle()

        validateTestRunnerInitialize()
        expect(testRunnerInitializeParams.testScope).toEqual('single')

      it "instantiates TestRunner and calls ::run on it", ->
        spyOnTestRunnerRun()

        view = new RubyTestView()
        view.testSingle()

        validateTestRunnerRun()

    describe "::testPrevious", ->
      it "intantiates TestRunner and calls ::run on it with specific arguments", ->
        spyOn(activeEditor, 'save')

        view = new RubyTestView()
        previousRunner = new TestRunner(view.testRunnerParams())
        previousRunner.command = -> "foo"
        view.runner = previousRunner
        view.testPrevious()

        expect(view.output).toBe("")
        expect(view.runner).toBe(previousRunner)
        expect(activeEditor.save).toHaveBeenCalled()

  describe "without open editor", ->
    beforeEach ->
      fileOpened = false
      testRunnerInitializeParams = null
      view = null

    # Reproduce https://github.com/moxley/atom-ruby-test/issues/33:
    # "Uncaught TypeError: Cannot read property 'save' of undefined"
    describe "::testAll", ->
      it "instantiates TestRunner and calls ::run on it", ->
        spyOnTestRunnerRun()

        view = new RubyTestView()
        view.testAll()

        expect(TestRunner.prototype.initialize).toHaveBeenCalled()
        expect(TestRunner.prototype.run).toHaveBeenCalledWith()


  describe "::write", ->
    it "appends content to results element", ->
      view = new RubyTestView()
      view.write("foo")
      expect(view.results.text()).toBe "foo"
