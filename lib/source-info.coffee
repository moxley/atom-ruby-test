module.exports =
  class SourceInfo
    frameworkLookup:
      test:    'test'
      spec:    'rspec'
      feature: 'cucumber'

    cwd: ->
      atom.project.getPath()

    testFileCommand: ->
      framework = @testFramework()
      atom.config.get("ruby-test.#{framework}FileCommand")

    testSingleCommand: ->
      framework = @testFramework()
      atom.config.get("ruby-test.#{framework}SingleCommand")

    activeFile: ->
      @_activeFile ||= atom.project.relativize(atom.workspace.getActiveEditor().buffer.file.path)

    currentLine: ->
      @_currentLine ||= unless @_currentLine
        editor = atom.workspace.getActiveEditor()
        cursor = editor.getCursor()
        cursor.getScreenRow() + 1

    testFramework: ->
      @_testFramework ||= unless @_testFramework
        (t = @fileType()) and @frameworkLookup[t]

    fileType: ->
      @_fileType ||= if matches = @activeFile().match(/_(test|spec)\.rb$/)
        matches[1]
      else if matches = @activeFile().match(/\.(feature)$/)
        matches[1]
