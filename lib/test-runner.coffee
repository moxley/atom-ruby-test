SourceInfo = require './source-info'
Command = require './command'
Utility = require './utility'

module.exports =
  class TestRunner
    constructor: (params, terminal) ->
      @initialize(params, terminal)

    initialize: (params, terminal) ->
      @terminal = terminal
      @params = params
      @sourceInfo = new SourceInfo()
      @utility = new Utility

    run: ->
      if atom.packages.isPackageDisabled('platformio-ide-terminal')
        alert("Platformio IDE Terminal package is disabled. It must be enabled to run tests.")
        return

      if (@terminal.lastTerminalForTest)
        # if we have a previous terminal opened from this test runner, close it
        @terminal.lastTerminalForTest.closeBtn.click()

      @returnFocusToEditorAfterTerminalRun();

      @terminal.run([@command()])
      terminals =  @terminal.getTerminalViews()
      @terminal.lastTerminalForTest = terminals[terminals.length - 1]

    returnFocusToEditorAfterTerminalRun: =>
      editor = @utility.editor()

      # If no files are open (we're running the entire suite) then
      # there is no cursor to return to
      return unless editor?

      cursorPos = editor.getCursorBufferPosition()

      # It appears that the terminal does not have create a panel until the
      # animation is complete. We need to wait for it to finish before we can
      # blur it to return focus
      setTimeout ->
        editor.setCursorBufferPosition(cursorPos, {autoscroll: true})
        panels = atom.workspace.getBottomPanels();
        for panel in panels
          if panel.getItem().hasClass?('platformio-ide-terminal')
            panel.getItem().blur()

        editor.getElement().focus()
      , 700


    command: =>
      framework = @sourceInfo.testFramework()
      cmd = Command.testCommand(@params.testScope, framework)
      cmd.replace('{relative_path}', @sourceInfo.activeFile()).
          replace('{line_number}', @sourceInfo.currentLine()).
          replace('{regex}', @sourceInfo.minitestRegExp())
