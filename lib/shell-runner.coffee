ChildProcess = require 'child_process'

module.exports =
  class ShellRunner
    constructor: (params) ->
      @initialize(params)

    initialize: (params) ->
      @params = params || throw "Missing ::params argument"
      @write = params.write || throw "Missing ::write parameter"
      @write = (data) => params.write "#{data}"
      @exit = params.exit || throw "Missing ::exit parameter"
      @command = params.command || throw "Missing ::command parameter"

    run: ->
      p = @newProcess()
      fullCommand = "cd #{@params.cwd()} && #{@params.command()}; exit\n"
      p.stdin.write fullCommand

    newProcess: ->
      spawn = ChildProcess.spawn
      terminal = spawn('bash', ['-l'])
      terminal.on 'close', =>
        @params.exit()
      terminal.stdout.on 'data', @write
      terminal.stderr.on 'data', @write
      terminal
