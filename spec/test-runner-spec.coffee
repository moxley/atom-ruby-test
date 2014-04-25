TestRunner = require './../lib/test-runner'

describe "TestRunner", ->
  beforeEach ->
    @writer = {
      file: 'Hello, world'
      output: ''
      write: (str) ->
        @output += str
      exit: ->
        @exited = true
    }
    @runner = new TestRunner(@writer)

  describe '::run', ->
    it "appends to writer", ->
      @runner.run()
      waitsFor ->
        @writer.exited
      runs ->
        expect(@writer.output).toBe "Hello, world"
