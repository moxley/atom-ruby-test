fs = require('fs')

module.exports =
  class SourceInfo
    frameworkLookup:
      test:    'test'
      spec:    'rspec'
      feature: 'cucumber'

    cwd: ->
      atom.project.getPath()

    testFileCommand: ->
      atom.config.get("ruby-test.#{@testFramework()}FileCommand")

    testAllCommand: ->
      configName = "ruby-test.#{@testFramework()}AllCommand"
      atom.config.get("ruby-test.#{@testFramework()}AllCommand")

    testSingleCommand: ->
      atom.config.get("ruby-test.#{@testFramework()}SingleCommand")

    activeFile: ->
      @_activeFile ||= atom.project.relativize(atom.workspace.getActiveEditor().buffer.file.path)

    currentLine: ->
      @_currentLine ||= unless @_currentLine
        editor = atom.workspace.getActiveEditor()
        cursor = editor.getCursor()
        cursor.getScreenRow() + 1

    testFramework: ->
      @_testFramework ||= unless @_testFramework
        (t = @fileType()) and @frameworkLookup[t] or
        @projectType()

    fileType: ->
      @_fileType ||= if matches = @activeFile().match(/_(test|spec)\.rb$/)
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
