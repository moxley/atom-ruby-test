ShellRunner = require './shell-runner'
TestParams = require './test-params'

module.exports =
  class TestRunner
    constructor: (params) ->
      @initialize params

    initialize: (params) ->
      @params = params
      @testParams = new TestParams()

    run: ->
      shell = new ShellRunner(@shellRunnerParams())
      @params.setTestInfo(@command())
      shell.run()

    shellRunnerParams: ->
      write:   @params.write
      exit:    @params.exit
      command: @command
      cwd:     @testParams.cwd

    command: =>
      cmd = if @params.testType == "single"
          @testParams.testSingleCommand()
        else
          @testParams.testFileCommand()
      cmd.replace('{relative_path}', @testParams.activeFile()).
          replace('{line_number}', @testParams.currentLine())
