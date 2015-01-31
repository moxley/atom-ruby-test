ResizeHandle = require '../lib/resize-handle'
RubyTestView = require '../lib/ruby-test-view'

describe "ResizeHandle", ->
  activationPromise = null

  beforeEach ->
    @view = new RubyTestView
    @resize = new ResizeHandle(@view)

  describe "when the resize handle is double clicked", ->
    beforeEach ->
      @view.showPanel()
      @panelBody = @view.find('.panel-body')
      @panelBody.height(10)

    it "sets the height of the panel to be the height of the content", ->
      @view.results.text("line1\nline2\nline3\nline4")
      @view.find('.ruby-test-resize-handle').trigger('dblclick')
      expect(@panelBody.height()).toBeGreaterThan(10);
      @panelBody.height(1000)
      @view.find('.ruby-test-resize-handle').trigger('dblclick')
      expect(@view.height()).toBeLessThan(1000)
