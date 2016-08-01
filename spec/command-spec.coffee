Command = require '../lib/command'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Command", ->
  describe "testSingleCommand", ->
    it "returns the ruby-test.rspecSingleCommand config value for the rspec framework", ->
      atom.config.set("ruby-test.rspecSingleCommand", "rspec command")
      actualValue = Command.testSingleCommand("rspec")
      expect(actualValue).toBe("rspec command")

    it "returns undefined when given an unrecognized framework", ->
      actualValue = Command.testSingleCommand("unknown")
      expect(actualValue).toBe(undefined)

  describe "testFileCommand", ->
    it "returns the ruby-test.rspecFileCommand config value for the rspec framework", ->
      atom.config.set("ruby-test.rspecFileCommand", "rspec command")
      actualValue = Command.testFileCommand("rspec")
      expect(actualValue).toBe("rspec command")

    it "returns the ruby-test.minitestFileCommand config value for the minitest framework", ->
      atom.config.set("ruby-test.minitestFileCommand", "minitest command")
      actualValue = Command.testFileCommand("minitest")
      expect(actualValue).toBe("minitest command")

    it "returns the ruby-test.cucumberFileCommand config value for the cucumber framework", ->
      atom.config.set("ruby-test.cucumberFileCommand", "cucumber command")
      actualValue = Command.testFileCommand("cucumber")
      expect(actualValue).toBe("cucumber command")

    it "returns undefined when given an unrecognized framework", ->
      actualValue = Command.testFileCommand("unknown")
      expect(actualValue).toBe(undefined)

  describe "testAllCommand", ->
    it "returns the ruby-test.rspecAllCommand config value for the rspec framework", ->
      atom.config.set("ruby-test.rspecAllCommand", "rspec command")
      actualValue = Command.testAllCommand("rspec")
      expect(actualValue).toBe("rspec command")

    it "returns undefined when given an unrecognized framework", ->
      actualValue = Command.testAllCommand("unknown")
      expect(actualValue).toBe(undefined)
