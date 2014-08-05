ChildProcess = require 'child_process'
{BufferedProcess} = require 'atom'

stdout = (output) -> console.log(output)

module.exports =
  class ShellRunner
    processor: BufferedProcess

    constructor: (params) ->
      @initialize(params)

    initialize: (params) ->
      @params = params || throw "Missing ::params argument"
      @write = params.write || throw "Missing ::write parameter"
      @write = (data) => params.write "#{data}"
      @exit = params.exit || throw "Missing ::exit parameter"
      @command = params.command || throw "Missing ::command parameter"

    run: ->
      fullCommand = "cd #{@params.cwd()} && #{@params.command()}; exit\n"
      @process = @newProcess(fullCommand)
      # @process.stdin.write fullCommand

    kill: ->
      console.log("Sending kill")
      @process.kill('SIGKILL')

    exit: (code) ->
      console.log "Exited with #{code}"
      @params.exit()

    newProcess: (testCommand) ->
      # process = ChildProcess.spawn('bash', ['-l'])
      command = 'bash'
      args = ['-c', testCommand]
      options = { cwd: @params.cwd, write: @params.write }
      process = new @processor { command, args, options, stdout, stdout, @exit }
      process
