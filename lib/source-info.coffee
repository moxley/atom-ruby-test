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
      atom.project.relativize(atom.workspace.getActiveEditor().buffer.file.path)

    currentLine: ->
      editor = atom.workspace.getActiveEditor()
      cursor = editor.getCursor()
      cursor.getScreenRow() + 1

    testFramework: ->
      t = @fileType()
      return null unless t
      @frameworkLookup[t]

    fileType: ->
      if matches = @activeFile().match(/_(test|spec)\.rb$/)
        matches[1]
      else if matches = @activeFile().match(/\.(feature)$/)
        matches[1]
