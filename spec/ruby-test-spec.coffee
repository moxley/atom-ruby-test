RubyTest = require '../lib/ruby-test'
RubyTestView = require '../lib/ruby-test-view'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RubyTest", ->
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)

  describe "when the ruby-test:test-file event is triggered", ->
    it "displays terminus", ->
      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'ruby-test:test-file'

      runs ->
        atom.packages.activatePackage('terminus').then ->
          expect(RubyTestView.prototype.initialize).toHaveBeenCalled()
