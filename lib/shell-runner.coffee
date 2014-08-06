ChildProcess = require 'child_process'

module.exports =
  class ShellRunner
    constructor: (params) ->
      @initialize(params)

    initialize: (params) ->
      @params = params || throw "Missing ::params argument"
      @write = params.write || throw "Missing ::write parameter"
      @write = (data) =>
        unless @killed
          params.write "#{data}"
      @exit = params.exit || throw "Missing ::exit parameter"
      @command = params.command || throw "Missing ::command parameter"

    run: ->
      fullCommand = "cd #{@params.cwd()} && #{@params.command()}; exit\n"
      @process = @newProcess()
      @process.stdin.write fullCommand

    kill: ->
      @killed = true
      if @process
        console.log("Sending kill")
        @process.kill('SIGKILL')

    newProcess: ->
      process = ChildProcess.spawn('bash', ['-l'])
      process.on 'close', =>
        console.log "Closing"
        @params.exit()
      process.stdout.on 'data', @write
      process.stderr.on 'data', @write
      process
