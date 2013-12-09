# the CLI upstream resolution narrative :[#022]

:#storypoint-10 introduction

premature as it may be, this is an (old) attempt to distill this commmon
logic of resolving one instream either from STDIN or from a file from
a filename, given the arguments.

this is very old but still working code. it was lifted almost as-is from
its original place (inside of the CLI client) and moved here as as a semi-
stable yet out of the way resting place.

currently it feels like a hack because of how automatic it tries to be:
it assumes that if you have one argument in argv and stdin is interactive,
then that one argument should be taken to repreesnt a filename.

#experimental: Figure out which of several possible datasources should
be the stream for reading from based on whether the instream (stdin)
is a tty (interactive terminal) or not, and whether arguments exist
in argv, and if so, whether the number of those argv arguments is one,
and if so, if it is a filename that can be read (whew!)

if it gets to this last case, (**NOTE**) it will mutate argv by
shifting this one arg off of it, it will open this filehandle (!!),
**and** store the open filehandle somewhere using some API call.
(but it is undefined here whether any existing open filehandle may
get overwritten by that call!! :#open-filehandle-1

this is an #experimental attempt to generalize this stuff, but is
still premature in its current state, hence [#022] will be
expected to be active for a while.

at this time there exists in headless CLI code an empty stub method
`resolve_upstream` that always results in true. human clients
may want to rewrite that method simply to call this method for e.g.

we wanted to use the name `r-esolve_upstream` for the below method
but that name is in common use already by other applications hand-
writing similar logic; hence we create a new name to avoid confusion.



:#storypoint-20 the way we interface with the client

as it stands this implementation is far better than its predecessor:
at least we have gotten the logic out of the main client. (this is one thing
we can say that for sure we would do different now than those years back:
we would not now build so many features into the client).

what we have lost is that now it is not hookable at all. so it was at this
sentence that we jumped over to writing [#139] the perfect agent interaction
model.

so this would serve as a good prototyping ground for that.
