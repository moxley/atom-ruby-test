ShellRunner = require './../lib/shell-runner'

class TestParams
  file: 'Hello, World!'
  output: ''
  write: (str) =>
    @output += str
  exit: =>
    @exited = true
  command: =>
    "echo -n #{@file}"
  cwd: =>
    "/tmp"

describe "ShellRunner", ->
  beforeEach ->
    @params = new TestParams()
    @runner = new ShellRunner(@params)

  describe '::run', ->
    it "appends to writer", ->
      @runner.run()
      waitsFor ->
        @params.exited
      runs ->
        expect(@params.output).toBe "Hello, World!"
