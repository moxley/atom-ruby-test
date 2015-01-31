RubyTest = require '../lib/ruby-test'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RubyTest", ->
  activationPromise = null
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('ruby-test')

  describe "when the ruby-test:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(workspaceElement.querySelector('.ruby-test')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'ruby-test:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.ruby-test')).toExist()
        atom.commands.dispatch workspaceElement, 'ruby-test:toggle'
        expect(workspaceElement.querySelector('.ruby-test')).not.toExist()
