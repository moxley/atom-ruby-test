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
      @terminal.run([@command()])

    command: =>
      framework = @sourceInfo.testFramework()
      cmd = Command.testCommand(@params.testScope, framework)
      cmd.replace('{relative_path}', @sourceInfo.activeFile()).
          replace('{line_number}', @sourceInfo.currentLine()).
          replace('{regex}', @sourceInfo.minitestRegExp())
