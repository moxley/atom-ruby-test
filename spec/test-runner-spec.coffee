TestRunner = require '../lib/test-runner'
SourceInfo = require '../lib/source-info'
Command = require '../lib/command'

describe "TestRunner", ->

  beforeEach ->
    @mockRun = jasmine.createSpy('run');
    @mockTerminal = { run: @mockRun }
    @testRunnerParams = {}

    spyOn(SourceInfo.prototype, 'activeFile').andReturn('fooTestFile')
    spyOn(SourceInfo.prototype, 'currentLine').andReturn(100)
    spyOn(SourceInfo.prototype, 'minitestRegExp').andReturn('test foo')
    spyOn(Command, 'testFileCommand').andReturn('fooTestCommand {relative_path}')
    spyOn(Command, 'testSingleCommand').andReturn('fooTestCommand {relative_path}:{line_number}')

  describe "::run", ->
    it "constructs a single-test command when testScope is 'single'", ->
      @testRunnerParams.testScope = "single"
      runner = new TestRunner(@testRunnerParams, @mockTerminal)
      runner.run()
      expect(@mockRun).toHaveBeenCalledWith(["fooTestCommand fooTestFile:100"])

    it "constructs a single-minitest command when testScope is 'single'", ->
      Command.testSingleCommand.andReturn('fooTestCommand {relative_path} -n \"/{regex}/\"')
      @testRunnerParams.testScope = "single"
      runner = new TestRunner(@testRunnerParams, @mockTerminal)
      runner.run()
      expect(@mockRun).toHaveBeenCalledWith(["fooTestCommand fooTestFile -n \"/test foo/\""])
