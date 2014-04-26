{BufferedProcess} = require 'atom'

module.exports =
  class TestRunner
    constructor: (params) ->
      @initialize(params)

    initialize: (params) ->
      @params = params
      @write = params.write
      @exit = params.exit
      @filePath = params.file

    run: ->
      p = @newProcess()
      fullCommand = "cd #{@params.cwd()} && #{@command()}; exit\n"
      console.log "fullCommand: #{fullCommand}"
      p.process.stdin.write fullCommand

    command: ->
      "#{@params.testCommand()} '#{@filePath}'"

    newProcess: ->
      new BufferedProcess
        command: 'bash',
        args:    ['-l'],
        stdout:  @write
        stderr:  @write
        exit:    =>
          @params.exit()
