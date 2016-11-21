## Handling cases where test details cannot be determined.

* Currently displays Atom's red exception popup, with an error that doesn't
  help the user at all.
* Does Atom have a notice-style popup? Maybe the missing test details can be
  displayed there.
  ```coffeescript
  atom.notifications.addWarning("test<br>test2")
  ```
* Gather information about the test first, check validity, then run it. If invalid,
  display what is wrong.
  * Example: User executes `ruby-test:test-all` command
    * ruby-test looks for `test` and `spec` folders, and doesn't find either.
    * ruby-test looks for `.rspec` file, and does not find it.
    * Result is saved to a TestDetails object and returned
    * The TestDetails object is checked for validity.
    * If invalid, an error message is composed: "I checked for a `test` folder,
      a `spec` folder, and a `.rspec` file in the project root (/path/to/project),
      and did not find evidence of a test framework."
  * Example: User executes `ruby-test:test-file` command on file called "user.rb",
    instead of a test or spec file.
    * ruby-test checks the filename and doesn't find a hint of the framework type.
    * ruby-test finds a `spec/` folder
    * ruby-test searches the contents of the file, and finds no clues about whether
      is is an RSpec or Minitest spec file.
    * Result is saved to a TestDetails object and returned.
    * The TestDetails object is checked for validity
    * If invalid, an error message is composed: "I checked the current filename
      for a hint about test framework style, and found none (e.g., user_test.rb
      for unit test, user_spec.rb for spec test). I searched the contents of the
      current file, and found no clues to the test framework, clues like the
      presence of `it "..." do`, or `def test_foo`, or `class TestFoo < MiniTest::Unit::TestCase`"

If there is a current file open, all test scopes should check the file for
test framework details.
