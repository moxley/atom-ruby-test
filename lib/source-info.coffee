fs = require('fs')
Utility = require './utility'

module.exports =
  # Provides information about the source code being tested
  class SourceInfo
    frameworkLookup:
      test:    'test'
      spec:    'rspec'
      feature: 'cucumber'
      minitest: 'minitest'

    matchers:
      method: /def\s(.*?)$/
      spec: /(?:"|')(.*?)(?:"|')/

    currentShell: ->
      atom.config.get('ruby-test.shell') || 'bash'

    cwd: ->
      atom.project.getPaths()[0]

    testFileCommand: ->
      atom.config.get("ruby-test.#{@testFramework()}FileCommand")

    testAllCommand: ->
      configName = "ruby-test.#{@testFramework()}AllCommand"
      atom.config.get("ruby-test.#{@testFramework()}AllCommand")

    testSingleCommand: ->
      atom.config.get("ruby-test.#{@testFramework()}SingleCommand")

    activeFile: ->
      @_activeFile ||= (fp = @filePath()) and atom.project.relativize(fp)

    currentLine: ->
      @_currentLine ||= unless @_currentLine
        editor = atom.workspace.getActiveTextEditor()
        cursor = editor and editor.getLastCursor()
        if cursor
          cursor.getBufferRow() + 1
        else
          null

    minitestRegExp: (text, type)->
      @_minitestRegExp ||= unless @_minitestRegExp
        value = text.match(@matchers[type]) if text?
        if value
          value[1]
        else
          ""

    isMiniTest: ->
      editor = atom.workspace.getActiveTextEditor()
      i = @currentLine() - 1
      regExp = null
      isSpec = false
      isUnit = false
      isRSpec = false
      specRegExp = new RegExp(/^(\s+)(should|test|it)\s+['""'](.*)['""']\s+do\s*(?:#.*)?$/)
      rspecRequireRegExp = new RegExp(/^require(\s+)['"](rails|spec)_helper['"]$/)
      minitestClassRegExp = new RegExp(/class\s(.*)<(\s?|\s+)Minitest::Test/)
      minitestMethodRegExp = new RegExp(/^(\s+)def\s(.*)$/)
      while i >= 0
        text = editor.lineTextForBufferRow(i)
        # check if it is rspec or minitest spec
        if !regExp && specRegExp.test(text)
          isSpec = true
          regExp = text
        # check if it is minitest unit
        else if !regExp && minitestMethodRegExp.test(text)
          isUnit = true
          regExp = text

        # if it is spec and has require spec_helper which means it is rspec spec
        else if rspecRequireRegExp.test(text)
          isRSpec = true
          break
        # if it is unit test and inherit from Minitest::Unit
        else if isUnit && minitestClassRegExp.test(text)
          @minitestRegExp(regExp, "method")
          return true

        i--

      if !isRSpec && isSpec
        @minitestRegExp(regExp, "spec")
        return true

      return false

    testFramework: ->
      @_testFramework ||= unless @_testFramework
        (fs.existsSync(@cwd() + '/.rspec') and 'rspec') or
        ((t = @fileType()) and @frameworkLookup[t]) or
        @projectType()

    fileType: ->
      @_fileType ||= if @_fileType == undefined
        if not @activeFile()
          null
        else if matches = @activeFile().match(/_?(test|spec)_?(.*)\.rb$/)
          if @isMiniTest()
            "minitest"
          else
            matches[1]
        else if matches = @activeFile().match(/\.(feature)$/)
          matches[1]

    projectType: ->
      if fs.existsSync(@cwd() + '/test')
        'test'
      else if fs.existsSync(@cwd() + '/spec')
        'rspec'
      else if fs.existsSync(@cwd() + '/feature')
        'cucumber'
      else
        null

    filePath: ->
      util = new Utility
      util.filePath()
