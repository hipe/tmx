# the CLI upstream resolution narrative :[#004]


## synopsis

given one [#ca-004] "arg" for a path (whose actual value is possibly
false-ish), and zero or one actual value for an "instream", resolve one
stream open for reading.




## interface theory

there is what the user passes to your action and then there is what
your action passes to this actor, which is [#fi-002] different:

your action passes to this actor zero or one instream (the IO object,
typically STDIN); and one [#ca-004] argument "trio" modeling both
the user's actual argument value for the `path` (if any was provided)
as well as modeling the formal value of the `path` (that is, metadata
about the field (like its name function) for use in event emission).

the actor assumes a different "input grammar" for your action based on
whether or not you pass the instream (typically STDIN): if you pass it,
it is assumed that your action will process *either* noninteractive STDIN
*or* a file. if you don't pass an instream, the actor assumes that your
input grammar is simply a single argument for the infile path name,
whose actual value is a path that should be opened for reading.

if (per what your action passes to the actor) your grammar is such that
you accept either STDIN or a path, when the instream and the actual value
for path are processed, input will be disambiguated (do we use STDIN or
path?) and, in case of either ambiguity or effectively missing argument(s)
an error event is emitted:

if any actual argument for path is present, this will make it "look" as
though it is supposed to be used. the instream "looks" as though it is
supposed to be used if it is present and non-interactive and open.

if in the actual arguments both "look" is if they are supposed to be used,
this is classified as ambiguous input and the result is an event emission
modelling the same.

if the argument instream is resolved unambiguousy as the one that is to be
used, the result is a call to the "success callback" (`as_normal_value`)
being passed this selfsame IO object that was passed in as an argument.
since the success callback defaults to the identity function, if a success
callback was not provided the final result of the actor in this case
is this IO object itself.

if the path is resolved unabiguously as the one that is to be used,
from this path the actor will attempt to produce a filehandle open for
reading. what are considered to be the commonest IO exceptions (file not
found, path is not file (e.g is directory)) are caught and the final
result is the emission of this exception turned somehow into an error event.

whether or not other system call exceptions related to this IO operation
will be corralled and turned into event emissions is formally undefined
(but they probably will be).

if the system call succeeds and the path is successfully opened for
reading, the final result of the actor will likewise be a call to the
success callback with this new IO object, open for reading.




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
still premature in its current state, hence [#004] will be
expected to be active for a while.

at this time there exists in headless CLI code an empty stub method
for resolving the upstream status (maybe a tuple?) that always results
in a success value (probably `true`). human clients may want to rewrite
that method simply to call this method, for e.g.

we wanted to use the name `r-esolve_upstream` for the below method
but that name is in common use already by other applications hand-
writing similar logic; hence we create a new name to avoid confusion.



:#storypoint-20 the way we interface with the client

as it stands this implementation is far better than its predecessor:
at least we have gotten the logic out of the main client. (this is one thing
we can say that for sure we would do different now than those years back:
we would not now build so many features into the client).

what we have lost is that now it is not hookable at all. so it was at this
sentence that we jumped over to writing [#hl-139] the perfect agent interaction
model.

so this would serve as a good prototyping ground for that.



## write

(this is for this other normalization, stowed away into here for now.)

### :#note-076

it is certainly possible that between the time when we take the "stat"
"snapshot" of the file and when we try to open the file that the file
may change or have been removed (or permissions may have changed so it
is not writable, and so-on: between then and now, assume that in this
interim literally anything that can happen on a filesystem may have
happened).

there may be multiple places with similar such issues here and in the
sibling nodes.

the existing logic may or may not account for that, but at least we
have it corralled into one place where it "should" be, and we have it
bookmarked for the future here, and it is hopefully abstracted away enough
not to affect the sorroundiing system too much.

code with filesystem locks always reads terribly and looks tangled and
bound so we are avoiding it if we can..
