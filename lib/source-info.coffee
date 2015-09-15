fs = require('fs')
Utility = require './utility'

module.exports =
  # Provides information about the source code being tested
  class SourceInfo
    frameworkLookup:
      test:    'test'
      spec:    'rspec'
      rspec:   'rspec'
      feature: 'cucumber'
      minitest: 'minitest'

    regExpForTestStyle:
      unit: /def\s(.*?)$/
      spec: /(?:"|')(.*?)(?:"|')/

    currentShell: ->
      atom.config.get('ruby-test.shell') || 'bash'

    projectPath: ->
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

    minitestRegExp: ->
      return @_minitestRegExp if @_minitestRegExp != undefined
      file = @fileAnalysis()
      @_minitestRegExp = @extractMinitestRegExp(file.testHeaderLine, file.testStyle)

    extractMinitestRegExp: (testHeaderLine, testStyle)->
      match = testHeaderLine? and testHeaderLine.match(@regExpForTestStyle[testStyle]) or null
      if match
        match[1]
      else
        ""

    isMiniTest: ->
      return @_isMiniTest if @_isMiniTest != undefined
      @fileAnalysis().isMiniTest

    fileAnalysis: ->
      return @_fileAnalysis if @_fileAnalysis != undefined

      @_fileAnalysis =
        testHeaderLine: null
        isSpec: false
        isUnit: false
        isRSpec: false
        isMiniTest: false

      editor = atom.workspace.getActiveTextEditor()
      i = @currentLine() - 1
      specRegExp = new RegExp(/\b(should|test|it)\s+['""'](.*)['""']\s+do\b/)
      rspecRequireRegExp = new RegExp(/^require(\s+)['"](rails|spec)_helper['"]$/)
      minitestClassRegExp = new RegExp(/class\s(.*)<(\s?|\s+)Minitest::Test/)
      minitestMethodRegExp = new RegExp(/^(\s+)def\s(.*)$/)
      while i >= 0
        sourceLine = editor.lineTextForBufferRow(i)

        if not @_fileAnalysis.testHeaderLine
          # check if it is rspec or minitest spec
          if specRegExp.test(sourceLine)
            @_fileAnalysis.isSpec = true
            @_fileAnalysis.testHeaderLine = sourceLine

          # check if it is minitest unit
          else if minitestMethodRegExp.test(sourceLine)
            @_fileAnalysis.isUnit = true
            @_fileAnalysis.testStyle = 'unit'
            @_fileAnalysis.testHeaderLine = sourceLine

        # if it is spec and has require spec_helper which means it is rspec spec
        else if rspecRequireRegExp.test(sourceLine)
          @_fileAnalysis.isRSpec = true
          @_fileAnalysis.isSpec = true
          @_fileAnalysis.testStyle = 'spec'
          break

        # if it is unit test and inherit from Minitest::Unit
        else if @_fileAnalysis.isUnit && minitestClassRegExp.test(sourceLine)
          @_fileAnalysis.isMiniTest = true
          return @_fileAnalysis

        i--

      if not @_fileAnalysis.isRSpec and @_fileAnalysis.isSpec
        @_fileAnalysis.isMiniTest = true

      @_fileAnalysis

    testFramework: ->
      @_testFramework ||= unless @_testFramework
        ((t = @fileType()) and @frameworkLookup[t]) or
        (fs.existsSync(@projectPath() + '/.rspec') and 'rspec') or
        @projectType()

    fileType: ->
      @_fileType ||= if @_fileType == undefined

        if not @activeFile()
          null
        else if matches = @activeFile().match(/_(test|spec)\.rb$/)
          if matches[1] == 'test' and atom.config.get("ruby-test.testFramework")
            atom.config.get("ruby-test.testFramework")
          else if matches[1] == 'spec' and atom.config.get("ruby-test.specFramework")
            atom.config.get("ruby-test.specFramework")
          else if @isMiniTest()
            'minitest'
          else if matches[1] == 'spec'
            'rspec'
          else
            'test'
        else if matches = @activeFile().match(/\.(feature)$/)
          matches[1]

    projectType: ->
      if fs.existsSync(@projectPath() + '/test')
        atom.config.get("ruby-test.testFramework") || 'test'
      else if fs.existsSync(@projectPath() + '/spec')
        atom.config.get("ruby-test.specFramework") || 'rspec'
      else if fs.existsSync(@projectPath() + '/features')
        'cucumber'
      else
        null

    filePath: ->
      util = new Utility
      util.filePath()
