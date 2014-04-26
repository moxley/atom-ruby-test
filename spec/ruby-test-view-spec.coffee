{$$, WorkspaceView} = require 'atom'
RubyTestView = require '../lib/ruby-test-view'
ShellRunner = require '../lib/shell-runner'

describe "RubyTestView", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView()

  describe "::run", ->
    it "instantiates ShellRunner, and calls ::run on it", ->
      spyOn(ShellRunner.prototype, 'initialize').andCallThrough()
      spyOn(ShellRunner.prototype, 'run').andCallThrough()
      atom.config.set("ruby-test.testCommand", 'fooCommand')

      @view = new RubyTestView()
      @view.activeFile = ->
        'Hello, World!'
      @view.run()
      expect(ShellRunner.prototype.initialize).toHaveBeenCalledWith(@view.testRunnerParams())
      expect(ShellRunner.prototype.run).toHaveBeenCalled()

  describe "::write", ->
    it "appends content to results element", ->
      @view = new RubyTestView()
      @view.write("foo")
      expect(@view.results.text()).toBe "foo"
