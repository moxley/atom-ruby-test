TestRunner = require '../lib/test-runner'
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

      runner = new TestRunner(testRunnerParams)
      spyOn(runner, 'command').andReturn 'fooTestCommand'
      runner.run()

      expect(ShellRunner.prototype.initialize).toHaveBeenCalledWith(runner.shellRunnerParams())
      expect(testRunnerParams.setTestInfo).toHaveBeenCalledWith(runner.command())
