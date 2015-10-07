# the skylab "filemetrics" utility

## objective & scope

SLOC and more: this is a collection of tools that makes reports using the
unix utilities
"find" and "wc" (wordcount) to show statistical information about files
in terms of the number of lines of code, and other things involving
the number and distribution of files in terms of their extensions, etc.

It can do things like:

  - show you a list of the filenames, from longest to shortest file,
    with their respective linecounts and what percentage of the
    maximum linecount that file is,

  - for each folder in PATH, match the files in the filename query and
    show summary information like above for each folder.

  - show the numbers of files of the different extension types


I find it useful when I am perusing a new library of code, and I want
to get a general sense for the composition and distribution of files.
Sometimes it is helpful to find the longest (or shortest) of a certain
type of file to use as a learning aide.

It can also be fun to see the statistical spread of how long or short
your files tend to be in one of your projects; possibly for use in an
aide in refactoring -- zeroing in on the longest and shortest files.
