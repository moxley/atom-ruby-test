# ruby-test package

[![Build Status](https://api.travis-ci.org/moxley/atom-ruby-test.svg?branch=master)](https://travis-ci.org/moxley/atom-ruby-test)

Run Ruby tests, Rspec examples, and Cucumber features from Atom,
quickly and easily.

![Running tests is quick and easy](http://cl.ly/image/300n2g101z0y/ruby-test6.gif)

## Install

In Atom's Settings, go to Packages, search for "Ruby Test".
Click the `Install` button.

## Configure

IMPORTANT: Before configuring ruby-test, toggle to the test panel to activate
the package: `cmd-ctrl-x`.

![Ruby Test Settings view](http://cl.ly/image/1l3H0g1C1J3g/ruby-test-settings.png)

**Shell**: executable or path to shell (e.g. `fish`, `/bin/zsh`)

## Run

Open the test file you want to run, then issue one of the following:

* `cmd-ctrl-y` - Run all the test files
* `cmd-ctrl-t` - Run the current test file
* `cmd-ctrl-r` - Run the test at the current line in test file
* `cmd-ctrl-e` - Re-run the previous test (doesn't need to have the test file active)
* `cmd-ctrl-x` - Show/hide the test panel

## Features

* Run all the tests in the project
* Run the tests for current test file
* Run single test at cursor
* Run previous test
* Configure the shell commands that run the tests
* Supports Ruby managers, like `rvm` and `rbenv`
* Supports bash, z-shell, fish
* Supports Test::Unit, Rspec, Minitest, and Cucumber

## Helpful Tips

* Use ruby-test in conjunction with [project-manager](https://atom.io/packages/project-manager)
  to maintain different ruby-test settings per project.
* [Run ruby-test on a project that runs in a VM or Vagrant](https://github.com/moxley/atom-ruby-test/blob/master/doc/running_against_vm.md)

## Contributing

Any of the following are appreciated:

* [Submit a Pull Request](https://github.com/moxley/atom-ruby-test/pulls)
* [Submit an Issue](https://github.com/moxley/atom-ruby-test/issues)
