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
    spyOn(TestRunner.prototype, 'initialize').andCallFake (params) ->
      testRunnerInitializeParams = params
    spyOn(TestRunner.prototype, 'run').andReturn(true)

  spyOnTestRunnerRun = ->
    spyOn(TestRunner.prototype, 'initialize').andCallThrough()
    spyOn(TestRunner.prototype, 'run').andCallThrough()

  spyOnRunTestExternalCalls = ->
    spyOnTestRunnerRun()
    spyOn(activeEditor, 'save')

  expectTestRunnerToBeInitialized = (scope) ->
    expect(testRunnerInitializeParams).toBeDefined()
    expect(testRunnerInitializeParams).not.toBe(null)
    expect(testRunnerInitializeParams.write).toEqual(view.write)
    expect(testRunnerInitializeParams.exit).toEqual(view.onTestRunEnd)
    expect(testRunnerInitializeParams.setTestInfo).toEqual(view.setTestInfo)
    expect(testRunnerInitializeParams.testScope).toEqual(scope)

  expectTestRunnerRunCalled = ->
    expect(TestRunner.prototype.initialize).toHaveBeenCalled()
    expect(TestRunner.prototype.run).toHaveBeenCalledWith()
    expect(activeEditor.save).toHaveBeenCalled()

  setUpActiveEditor = ->
    fileOpened = false
    atom.workspace.open('/tmp/user_test.rb').then (editor) ->
      activeEditor = editor
      fileOpened = true
    waitsFor -> fileOpened is true

  setUpForTestFileRun = ->
    setUpActiveEditor()

  describe "with open editor", ->
    beforeEach ->
      testRunnerInitializeParams = null
      view = null
      activeEditor = null
      setUpForTestFileRun()

    describe "::runTest('all')", ->
      it "instantiates TestRunner with specific arguments", ->
        spyOnTestRunnerInitialize()
        view = new RubyTestView()
        view.runTest("all")
        expectTestRunnerToBeInitialized('all')

    describe "::runTest('file')", ->
      it "calls ::run on the TestRunner instance", ->
        atom.config.set("ruby-test.testFileCommand", "test test/foo_test.rb")
        spyOnRunTestExternalCalls()

        view = new RubyTestView()
        spyOn(view, 'setTestInfo').andCallThrough()
        view.runTest("file")

        expectTestRunnerRunCalled()

        expect(view.setTestInfo).toHaveBeenCalled()
        expect(view.spinner).toShow()

    describe "::runTest('single')", ->
      it "instantiates TestRunner with specific arguments", ->
        spyOnTestRunnerInitialize()

        view = new RubyTestView()
        view.runTest("single")

        expectTestRunnerToBeInitialized('single')

      it "instantiates TestRunner and calls ::run on it", ->
        spyOnRunTestExternalCalls()

        view = new RubyTestView()
        view.runTest("single")

        expectTestRunnerRunCalled()

    describe "::testPrevious", ->
      it "intantiates TestRunner and calls ::run on it with specific arguments", ->
        spyOnRunTestExternalCalls()

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
      testRunnerInitializeParams = null
      view = null

    # Reproduce https://github.com/moxley/atom-ruby-test/issues/33:
    # "Uncaught TypeError: Cannot read property 'save' of undefined"
    describe "::runTest('all')", ->
      it "instantiates TestRunner and calls ::run on it", ->
        spyOnRunTestExternalCalls()

        view = new RubyTestView()
        view.runTest("all")

        expect(TestRunner.prototype.initialize).toHaveBeenCalled()
        expect(TestRunner.prototype.run).toHaveBeenCalledWith()

  describe "::write", ->
    it "appends content to results element", ->
      view = new RubyTestView()
      view.write("foo")
      expect(view.results.text()).toBe "foo"
