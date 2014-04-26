{$$, WorkspaceView} = require 'atom'
RubyTestView = require '../lib/ruby-test-view'
TestRunner = require '../lib/test-runner'

describe "RubyTestView", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView()

  describe "::run", ->
    it "instantiates TestRunner, and calls ::run on it", ->
      spyOn(TestRunner.prototype, 'initialize').andCallThrough()
      spyOn(TestRunner.prototype, 'run').andCallThrough()
      spyOn(TestRunner.prototype, 'command').andReturn 'fooTestCommand'

      @view = new RubyTestView()
      spyOn(@view, 'setTestInfo').andCallThrough()
      @view.run()
      expect(TestRunner.prototype.initialize).toHaveBeenCalledWith(@view.testRunnerParams())
      expect(TestRunner.prototype.run).toHaveBeenCalled()
      expect(@view.setTestInfo).toHaveBeenCalled()

  describe "::write", ->
    it "appends content to results element", ->
      @view = new RubyTestView()
      @view.write("foo")
      expect(@view.results.text()).toBe "foo"
