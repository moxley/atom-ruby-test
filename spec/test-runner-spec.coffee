TestRunner = require '../lib/test-runner'
SourceInfo = require '../lib/source-info'
ShellRunner = require '../lib/shell-runner'
Command = require '../lib/command'

describe "TestRunner", ->

  emptySourceInfoValues =
    activeFile: null,
    currentLine: null,
    minitestRegExp: null,
  validSourceInfoValues =
    activeFile: 'fooTestFile',
    currentLine: 100,
    minitestRegExp: 'test foo',

  spyOnSourceInfo = (vals) ->
    spyOn(SourceInfo.prototype, 'activeFile').andReturn(vals.activeFile)
    spyOn(SourceInfo.prototype, 'currentLine').andReturn(vals.currentLine)
    spyOn(SourceInfo.prototype, 'minitestRegExp').andReturn(vals.minitestRegExp)

  beforeEach ->
    spyOn(ShellRunner.prototype, 'initialize').andCallThrough()
    @testRunnerParams =
      write:             => null
      exit:              => null
      shellRunnerParams: => null
      setTestInfo:       => null
    spyOn(@testRunnerParams, 'shellRunnerParams')
    spyOn(@testRunnerParams, 'setTestInfo')

  describe "::run", ->
    it "fails gracefully on test-file when no test framework could be determined", ->
      spyOnSourceInfo(emptySourceInfoValues)
      @testRunnerParams.testScope = "file"
      spyOn(Command, 'testFileCommand').andReturn(null)
      runner = new TestRunner(@testRunnerParams)
      runner.run()
      expect(@testRunnerParams.setTestInfo).toHaveBeenCalledWith("Failed to calculate test command")

    it "constructs a single-test command when testScope is 'single'", ->
      spyOnSourceInfo(validSourceInfoValues)
      @testRunnerParams.testScope = "single"
      spyOn(Command, 'testSingleCommand').andReturn("fooTestCommand fooTestFile:100")
      runner = new TestRunner(@testRunnerParams)
      runner.run()
      expect(@testRunnerParams.setTestInfo).toHaveBeenCalledWith("fooTestCommand fooTestFile:100")

    it "constructs a single-minitest command when testScope is 'single'", ->
      spyOnSourceInfo(validSourceInfoValues)
      spyOn(Command, 'testSingleCommand').andReturn('fooTestCommand {relative_path} -n \"/{regex}/\"')
      @testRunnerParams.testScope = "single"
      runner = new TestRunner(@testRunnerParams)
      runner.run()
      expect(@testRunnerParams.setTestInfo).toHaveBeenCalledWith("fooTestCommand fooTestFile -n \"/test foo/\"")
