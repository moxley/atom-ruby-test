SourceInfo = require './source-info'
Command = require './command'

module.exports =
  class TestRunner
    constructor: (params, terminal) ->
      @initialize(params, terminal)

    initialize: (params, terminal) ->
      @terminal = terminal
      @params = params
      @sourceInfo = new SourceInfo()

    run: ->
      if atom.packages.isPackageDisabled('platformio-ide-terminal')
        alert("Platformio IDE Terminal package is disabled. It must be enabled to run tests.")
        return

      if (@terminal.lastTerminalForTest)
        # if we have a previous terminal opened from this test runner, close it
        @terminal.lastTerminalForTest.closeBtn.click()

      @terminal.run([@command()])
      terminals =  @terminal.getTerminalViews()
      @terminal.lastTerminalForTest = terminals[terminals.length - 1]

    command: =>
      framework = @sourceInfo.testFramework()
      cmd = Command.testCommand(@params.testScope, framework)
      cmd.replace('{relative_path}', @sourceInfo.activeFile()).
          replace('{line_number}', @sourceInfo.currentLine()).
          replace('{regex}', @sourceInfo.minitestRegExp())
