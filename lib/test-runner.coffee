{BufferedProcess} = require 'atom'

module.exports =
  class TestRunner
    constructor: (writer) ->
      @initialize(writer)

    initialize: (writer) ->
      @writer = writer

    run: ->
      p = @newProcess()
      p.process.stdin.write "echo -n 'Hello, world' && exit\n"

    newProcess: ->
      new BufferedProcess
        command: 'bash',
        args:    ['-l'],
        stdout:  @write,
        stderr:  @write,
        exit:    @exit

    write: (str) =>
      @writer.write(str)

    exit: =>
      @writer.exit()
