# the path tools narrative :[#005]

## as an open issue - unify pretty path

there are two main issues with the current implementation of "pretty
path", one superficial and one deep. 1) (the superficial one) is its
placement - because its behavior does not intimitely relate with a
client-generating library and it does relate itimately with the
filesystem, we say that the implementation facilities should be moved to
[sy], but because it's an often used feature in CLI, we will have
built-in integration in expags in CLI generators.

2) is the deeper issue: some of subject's main functions require as
arguments (variously) the current working directory and the
`ENV['HOME']` environment variable.

2A) access to *both* these values should happen thru "conduits" (a
filesystem conduit and an environment conduit or equivalent). these
conduits should be "injected" into the pretty path "session" by its
constructor (probably the main modality client (e.g "CLI")). as they are
written now they are more function-oriented and less of a session-oriented
shape that would accomodate this.

2B) is that we should revisit the design of subject's dependence on
knowing when `pwd` changes. there are a variety of possibilities:

  • the file conduit could maintain a subscribers list. all pwd changes
    would then must happen through it. one downside to this approach is
    that we lose the clean relationship between the file conduit
    "interface" and the platform `::File`'s interface.

  • the client of the subject session would must call "session start" or
    the like whenever it is at the (pre) beginning of a "batch"-like
    session. we like this better because it has a smaller impact on the
    greater universe, but requires client knowledge and code.




## :#the-issue-with-pretty-path-and-caching

`pretty_path` is designed to scale to a large number of filepaths scrolling
by, possibly thousands. it generates regexen to match paths that contain `pwd`
and `$HOME` at their heads. to read the value of `pwd` and build a regex anew
each time it needs to prettify a path does not scale well to large numbers of
paths (and just feels wrong), hence these things are memoized.

however it is perfectly reasonable that some programs use `cd` during the
course of their execution, which will then out of the box render
`pretty_path` broken iff it is used while in more than one `present
working directory`'

in such cases the program *must* call `PathTools.clear` in between times
that the current working directory changes and the time that they use
`pretty_path`; otherwise it will be using stale regexen.

(if the above is a showstopper, the below can be pretty easily bent
to for example take a boolean "clear cache" flag parameter
to `pretty_path`) ..
