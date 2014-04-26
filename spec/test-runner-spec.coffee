TestRunner = require '../lib/test-runner'
TestParams = require '../lib/test-params'
ShellRunner = require '../lib/shell-runner'

describe "TestRunner", ->
  describe "::run", ->
    it "Instantiates ShellRunner with expected params", ->
      spyOn(ShellRunner.prototype, 'initialize').andCallThrough()
      testRunnerParams =
        write:             => null
        exit:              => null
        shellRunnerParams: => null
        setTestInfo:       => null
      spyOn(testRunnerParams, 'shellRunnerParams')
      spyOn(testRunnerParams, 'setTestInfo')
      spyOn(TestParams.prototype, 'command').andReturn('fooTestCommand {relative_path}')
      spyOn(TestParams.prototype, 'activeFile').andReturn('fooTestFile')

      runner = new TestRunner(testRunnerParams)
      runner.run()

      expect(ShellRunner.prototype.initialize).toHaveBeenCalledWith(runner.shellRunnerParams())
      expect(testRunnerParams.setTestInfo).toHaveBeenCalledWith("fooTestCommand fooTestFile")
