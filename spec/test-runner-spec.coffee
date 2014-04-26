TestRunner = require '../lib/test-runner'
TestParams = require '../lib/test-params'
ShellRunner = require '../lib/shell-runner'

describe "TestRunner", ->
  beforeEach ->
    spyOn(ShellRunner.prototype, 'initialize').andCallThrough()
    @testRunnerParams =
      write:             => null
      exit:              => null
      shellRunnerParams: => null
      setTestInfo:       => null
    spyOn(@testRunnerParams, 'shellRunnerParams')
    spyOn(@testRunnerParams, 'setTestInfo')
    spyOn(TestParams.prototype, 'activeFile').andReturn('fooTestFile')
    spyOn(TestParams.prototype, 'currentLine').andReturn(100)
    spyOn(TestParams.prototype, 'testFileCommand').andReturn('fooTestCommand {relative_path}')
    spyOn(TestParams.prototype, 'testSingleCommand').andReturn('fooTestCommand {relative_path}:{line_number}')

  describe "::run", ->
    it "Instantiates ShellRunner with expected params", ->

      runner = new TestRunner(@testRunnerParams)
      runner.run()

      expect(ShellRunner.prototype.initialize).toHaveBeenCalledWith(runner.shellRunnerParams())
      expect(@testRunnerParams.setTestInfo).toHaveBeenCalledWith("fooTestCommand fooTestFile")

    it "constructs a single-test command when testType is 'single'", ->
      @testRunnerParams.testType = "single"
      runner = new TestRunner(@testRunnerParams)
      runner.run()
      expect(@testRunnerParams.setTestInfo).toHaveBeenCalledWith("fooTestCommand fooTestFile:100")
