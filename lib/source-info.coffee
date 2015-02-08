fs = require('fs')
Utility = require './utility'

module.exports =
  # Provides information about the source code being tested
  class SourceInfo
    frameworkLookup:
      test:    'test'
      spec:    'rspec'
      feature: 'cucumber'

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
        cursor = editor and editor.getCursor()
        if cursor
          cursor.getBufferRow() + 1
        else
          null

    testFramework: ->
      @_testFramework ||= unless @_testFramework
        (t = @fileType()) and @frameworkLookup[t] or
        @projectType()

    fileType: ->
      @_fileType ||= if @_fileType == undefined
        if not @activeFile()
          null
        else if matches = @activeFile().match(/_(test|spec)\.rb$/)
          matches[1]
        else if matches = @activeFile().match(/\.(feature)$/)
          matches[1]

    projectType: ->
      if fs.existsSync(atom.project.path + '/test')
        'test'
      else if fs.existsSync(atom.project.path + '/spec')
        'rspec'
      else if fs.existsSync(atom.project.path + '/feature')
        'cucumber'
      else
        null

    filePath: ->
      util = new Utility
      util.filePath()
