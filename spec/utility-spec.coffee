Utility = require '../lib/utility'

describe "Utility", ->
  describe "::saveFile", ->
    makeEditor = (opts) ->
      editor = {
        save: null
        buffer: {file: {path: opts.path}}
      }
      spyOn(editor, 'save')
      spyOn(atom.workspace, 'getActiveTextEditor').andReturn(editor)
      editor

    it "calls save() on the active editor file", ->
      editor = makeEditor(path: 'foo/bar.rb')

      util = new Utility
      util.saveFile()

      expect(editor.save).toHaveBeenCalled()

    it "does not call save() when there is no file path", ->
      editor = makeEditor(path: null)

      util = new Utility
      util.saveFile()

      expect(editor.save).not.toHaveBeenCalled()
