{BufferedProcess} = require 'atom'

module.exports =
  class TestRunner
    constructor: (listener) ->
      @initialize(listener)

    initialize: (listener) ->
      @listener = listener

    run: ->
      p = @newProcess()
      p.process.stdin.write "#{@command()}; exit\n"

    command: ->
      "echo -n '#{@listener.file}'"

    newProcess: ->
      new BufferedProcess
        command: 'bash',
        args:    ['-l'],
        stdout:  @write,
        stderr:  @write,
        exit:    @exit

    write: (str) =>
      @listener.write(str)

    exit: =>
      @listener.exit()
