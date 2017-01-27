RubyTest = require '../lib/ruby-test'
RubyTestView = require '../lib/ruby-test-view'

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

  describe "when the ruby-test:test-file event is triggered", ->
    it "displays the platformio-ide-terminal", ->
      spyOn(RubyTestView.prototype, 'initialize').andReturn({ destroy: -> })

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'ruby-test:test-file'

      waitsForPromise ->
        require('atom-package-deps').install('ruby-test')

      waitsForPromise ->
        # atom.packages.activatePackage('ruby-test')
        activationPromise

      runs ->
        atom.packages.activatePackage('platformio-ide-terminal').then ->
          expect(RubyTestView.prototype.initialize).toHaveBeenCalled()
