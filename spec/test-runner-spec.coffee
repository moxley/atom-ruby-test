TestRunner = require './../lib/test-runner'

class TestParams
  file: 'Hello, World!'
  output: ''
  write: (str) =>
    @output += str
  exit: =>
    @exited = true
  testCommand: ->
    'echo -n'
  cwd: ->
    '/tmp'

describe "TestRunner", ->
  beforeEach ->
    @params = new TestParams()
    @runner = new TestRunner(@params)

  describe '::run', ->
    it "appends to writer", ->
      @runner.run()
      waitsFor ->
        @params.exited
      runs ->
        expect(@params.output).toBe "Hello, World!"
