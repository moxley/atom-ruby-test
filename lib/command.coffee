module.exports =
  # Calculates test command, based on test framework and test scope
  class Command
    @testCommand: (scope, testFramework) ->
      if scope == "single"
        @testSingleCommand(testFramework)
      else if scope == "file"
        @testFileCommand(testFramework)
      else if scope == "all"
        @testAllCommand(testFramework)
      else
        throw "Unknown scope: #{scope}"

    @testFileCommand: (testFramework) ->
      atom.config.get("ruby-test.#{testFramework}FileCommand")

    @testAllCommand: (testFramework) ->
      atom.config.get("ruby-test.#{testFramework}AllCommand")

    @testSingleCommand: (testFramework) ->
      atom.config.get("ruby-test.#{testFramework}SingleCommand")
