BufferedProcess = require './buffered-process'

module.exports =
  class ShellRunner
    processor: BufferedProcess

    constructor: (params) ->
      @initialize(params)

    initialize: (params) ->
      @params = params || throw "Missing ::params argument"
      @write = params.write || throw "Missing ::write parameter"
      @exit = params.exit || throw "Missing ::exit parameter"
      @command = params.command || throw "Missing ::command parameter"
      @currentShell = params.currentShell || throw "Missing ::currentShell parameter"

    run: ->
      @process = @newProcess(@fullCommand())

    fullCommand: ->
      "cd #{@escape(@params.cwd())} && #{@params.command()}; exit\n"

    escape: (str) ->
      charsToEscape = "\\ \t\"'$()[]<>&|*;~`#"
      out = ''
      for ch in str
        if charsToEscape.indexOf(ch) >= 0
          out += '\\' + ch
        else
          out += ch
      out

    kill: ->
      if @process?
        @process.kill('SIGKILL')

    stdout: (output) =>
      @params.write output

    stderr: (output) =>
      @params.write output

    newProcess: (testCommand) ->
      command = @currentShell
      args = ['-c', '-l', testCommand]
      options = { cwd: @params.cwd }
      params = { command, args, options, @stdout, @stderr, @exit }
      outputCharacters = true
      process = new @processor params, outputCharacters
      process
