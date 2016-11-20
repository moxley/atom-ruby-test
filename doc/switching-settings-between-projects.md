## How To Switch Settings Between Projects

Use this technique to switch to a different project and have
your ruby-test settings change with it.

1. Install the `project-manager` Atom package. This gives you project-specific
   settings for any Atom package, not just ruby-test.
2. Open the project you want different ruby-test settings for.
3. Execute the "Project Manager: Edit Project" (singular) Atom command
   (Press `⇧⌘P` Mac to access the commands).
4. Fill out the fields for your project.
5. Execute the "Project Manager: Edit Projects" (plural) command. This will
   open a CSON file containing project settings of all your projects.
6. Find your project, and add this bit of code to it:
```
    settings:
      "ruby-test":
        specFramework: "rspec"
        minitestFileCommand: "bundle exec m {relative_path}"
        minitestSingleCommand: "bundle exec m {relative_path}:{line_number}"
        minitestAllCommand: "bundle exec m spec/*"
```
7. Change the code above to the values needed for your project.
8. Now, next time you want to open your project, execute the
   "Project Manager: List Projects" command (`^⌘P` Mac), and enter your
   project's name. When it opens, it'll have the correct ruby-test settings.
