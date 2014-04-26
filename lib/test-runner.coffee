ShellRunner = require './shell-runner'

module.exports =
  class TestRunner
    constructor: (params) ->
      @initialize params

    initialize: (params) ->
      @params = params

    run: ->
      shell = new ShellRunner(@shellRunnerParams())
      @params.setTestInfo(@command())
      shell.run()

    shellRunnerParams: ->
      write:   @params.write
      exit:    @params.exit
      command: @command
      cwd:     @cwd

    cwd: =>
      atom.project.getPath()

    command: =>
      atom.config.get("ruby-test.testCommand").
                  replace('{relative_path}', @activeFile())

    activeFile: ->
      atom.project.relativize(atom.workspace.getActiveEditor().buffer.file.path)
