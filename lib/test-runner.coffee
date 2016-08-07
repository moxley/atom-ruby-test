ShellRunner = require './shell-runner'
SourceInfo = require './source-info'
Command = require './command'

module.exports =
  class TestRunner
    constructor: (params) ->
      @initialize params

    initialize: (params) ->
      @params = params
      @sourceInfo = new SourceInfo()

    run: ->
      @shell = new ShellRunner(@shellRunnerParams())
      cmd = @command()
      if cmd
        @params.setTestInfo(cmd)
        @shell.run()
        true
      else
        @params.setTestInfo("Failed to calculate test command")
        false

    shellRunnerParams: ->
      write:   @params.write
      exit:    @params.exit
      command: @command
      cwd:     => @sourceInfo.projectPath()
      currentShell: @sourceInfo.currentShell()

    command: =>
      framework = @sourceInfo.testFramework()
      cmd = Command.testCommand(@params.testScope, framework)
      cmd and cmd.replace('{relative_path}', @sourceInfo.activeFile()).
      replace('{line_number}', @sourceInfo.currentLine()).
      replace('{regex}', @sourceInfo.minitestRegExp())

    cancel: ->
      @shell.kill()
