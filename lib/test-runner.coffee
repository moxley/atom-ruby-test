ShellRunner = require './shell-runner'
SourceInfo = require './source-info'

module.exports =
  class TestRunner
    constructor: (params) ->
      @initialize params

    initialize: (params) ->
      @params = params
      @testParams = new SourceInfo()

    run: ->
      @shell = new ShellRunner(@shellRunnerParams())
      @params.setTestInfo(@command())
      @shell.run()

    shellRunnerParams: ->
      write:   @params.write
      exit:    @params.exit
      command: @command
      cwd:     @testParams.projectPath
      currentShell: @testParams.currentShell()

    command: =>
      cmd = if @params.testScope == "single"
          @testParams.testSingleCommand()
        else if @params.testScope == "all"
          @testParams.testAllCommand()
        else
          @testParams.testFileCommand()
      cmd.replace('{relative_path}', @testParams.activeFile()).
          replace('{line_number}', @testParams.currentLine()).
          replace('{regex}', @testParams.minitestRegExp())

    cancel: ->
      @shell.kill()
