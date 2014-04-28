{WorkspaceView} = require 'atom'
ResizeHandle = require '../lib/resize-handle'
RubyTestView = require '../lib/ruby-test-view'

describe "ResizeHandle", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    @view = new RubyTestView
    @resize = new ResizeHandle(@view)

  describe "when the resize handle is double clicked", ->
    beforeEach ->
      @view.showPanel()
      @view.height(10).find('.ruby-test').height(100)

    it "sets the height of the panel to be the height of the content", ->
      expect(@view.height()).toBe(10)
      @view.find('.ruby-test-resize-handle').trigger('dblclick')
      expect(@view.height()).toBeGreaterThan(10);
      @view.height(1000)
      @view.find('.ruby-test-resize-handle').trigger('dblclick')
      expect(@view.height()).toBeLessThan(1000)
