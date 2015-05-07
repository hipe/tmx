# the path tools narrative :[#005]


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
