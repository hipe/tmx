filemetrics

This is a wrapper around the unix utilities 'find' and 'wc' (wordcount)
that finds all files in a tree matching a certain pattern
(e.g. '*.rb', '*.php', '*.js',  or some boolean combination thereof)
and can either:
  - show you a list of the filenames, from longest to shortest file,
      with their repsective linecounts and what percentage of the
      maximum linecount that file is,
  or:
  - for each folder in PATH match the files in the filename query and
    show summary information like above for each folder.


I have only used this twice, but the second time I needed it I was glad
it was there.  Both times I used it was when I was looking at a new library
and trying to find example code (e.g. of unit tests or of jquery plugins)
and I wanted to find either the longest or the shortest such example
to learn from.

It can also be fun to see the statistical spread of how long or short
your files tend to be in one of your projects.
