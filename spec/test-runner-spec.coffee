TestRunner = require './../lib/test-runner'

describe "TestRunner", ->
  beforeEach ->
    @writer = {
      output: ''
      write: (str) ->
        @output += str
    }
    @runner = new TestRunner(@writer)

  describe '::run', ->
    it "appends to writer", ->
      @runner.run()
      expect(@writer.output).toBe "Hello, world"
