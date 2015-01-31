_ = require 'underscore-plus'
{$$} = require 'atom-space-pen-views'
RubyTestView = require '../lib/ruby-test-view'
TestRunner = require '../lib/test-runner'

describe "RubyTestView", ->
  activeEditor = null

  beforeEach ->
    fileOpened = false

    atom.workspace.open('/tmp/text.txt').then (editor) ->
      activeEditor = editor
      fileOpened = true

    # editor = atom.workspace.getActiveTextEditor()
    # editor.open('/tmp/text.txt').then -> fileOpened = true

    waitsFor -> fileOpened is true

  describe "::testFile", ->
    it "instantiates TestRunner, and calls ::run on it", ->
      spyOn(activeEditor, 'save')
      spyOn(TestRunner.prototype, 'initialize').andCallThrough()
      spyOn(TestRunner.prototype, 'run').andCallThrough()
      spyOn(TestRunner.prototype, 'command').andReturn 'fooTestCommand'

      @view = new RubyTestView()
      spyOn(@view, 'setTestInfo').andCallThrough()
      @view.testFile()

      expect(TestRunner.prototype.initialize).toHaveBeenCalledWith(@view.testRunnerParams())
      expect(TestRunner.prototype.run).toHaveBeenCalled()
      expect(@view.setTestInfo).toHaveBeenCalled()
      # expect(@view.hasParent()).toBe(true)
      expect(activeEditor.save).toHaveBeenCalled()

  describe "::testSingle", ->
    it "intantiates TestRunner and calls ::run on it with specific arguments", ->
      spyOn(activeEditor, 'save')
      spyOn(TestRunner.prototype, 'initialize').andCallThrough()
      spyOn(TestRunner.prototype, 'run').andCallThrough()
      spyOn(TestRunner.prototype, 'command').andReturn 'fooTestCommand'

      @view = new RubyTestView()
      @view.testSingle()

      params = _.extend({}, @view.testRunnerParams(), {testScope: "single"})
      expect(TestRunner.prototype.initialize).toHaveBeenCalledWith(params)
      expect(TestRunner.prototype.run).toHaveBeenCalled()
      expect(activeEditor.save).toHaveBeenCalled()

  describe "::testPrevious", ->
    it "intantiates TestRunner and calls ::run on it with specific arguments", ->
      spyOn(activeEditor, 'save')

      @view = new RubyTestView()
      previousRunner = new TestRunner(@view.testRunnerParams())
      previousRunner.command = -> "foo"
      @view.runner = previousRunner
      @view.testPrevious()

      expect(@view.output).toBe("")
      expect(@view.runner).toBe(previousRunner)
      expect(activeEditor.save).toHaveBeenCalled()

  describe "::write", ->
    it "appends content to results element", ->
      @view = new RubyTestView()
      @view.write("foo")
      expect(@view.results.text()).toBe "foo"
