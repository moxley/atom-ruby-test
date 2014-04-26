{BufferedProcess} = require 'atom'

module.exports =
  class ShellRunner
    constructor: (params) ->
      @initialize(params)

    initialize: (params) ->
      @params = params || throw "Missing ::params argument"
      @write = params.write || throw "Missing ::write parameter"
      @exit = params.exit || throw "Missing ::exit parameter"
      @command = params.command || throw "Missing ::command parameter"

    run: ->
      p = @newProcess()
      fullCommand = "cd #{@params.cwd()} && #{@params.command()}; exit\n"
      p.process.stdin.write fullCommand

    newProcess: ->
      new BufferedProcess
        command: 'bash',
        args:    ['-l'],
        stdout:  @write
        stderr:  @write
        exit:    =>
          @params.exit()
