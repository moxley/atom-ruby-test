module.exports =
  class TestRunner
    constructor: (writer) ->
      @initialize(writer)

    initialize: (writer) ->
      @writer = writer

    run: ->
      @writer.write("Hello, world")
