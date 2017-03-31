# the normalizers :[#004]

## T.O.C and our general ordering rational :[#here.A]

the test files are numbered in general because [#ts-001.3].

there are holes in the sequence because [#sl-137.H].

we make the lettered sections here correspond to the numbers there
because hey why not (note we use the holes for our own nodes):

  • [#here.A]: (here)
  • [#here.B]: upstream IO
  • [#here.C]: unlink file
  • [#here.D]: downstream IO
  • [#here.E]: (this common algorithm)
  • [#here.F]: existent directory
  • [#here.G]: path-based normalizations
  • [#here.H]: (below)
  • [#here.9]: track the volatility/mutex issue of all filesystems

[#here.G] has a general introduction to why these are "normalizers" and what
that means.




## the upstream IO normalization  :[#here.B]

at essence this node can be summarized as "open an existing file for
reading". its primary reason for existence, however, is:


### the commmon upstream resolution algorithm :[#here.E]


#### synopsis

given one [#ca-004] "arg" for a path (which may represent a known
unknown), and zero or one actual value for an "instream" (typically
something like a STDIN), resolve one stream open for reading.




#### synopsis in pseudocode

if an actual value is know for a `path` property, this is a thing.

if an "instream" was passed and is non-interactive, this is also a thing.

the above two are mutex: they can't both be things.

however, if only the first thing was a thing, process it as a path
argument as normal.

otherwise, if the second thing was a thing, this is the value of the
result argument and we are done.

in the absence of both of these things, this case is outside
of this scope.




#### interface theory (EDIT: this is like rings of an ooolllddd tree..)

there is what the user passes to your action and then there is what
your action passes to this actor, which is different:

your action passes to this actor zero or one instream (the IO object,
typically STDIN); and one [#ca-004] "qualified knownness" modeling both
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

if the path is resolved unabiguously as the one that is to be used,
from this path the actor will attempt to produce a filehandle open for
reading. what are considered to be the commonest IO exceptions (file not
found, path is not file (e.g is directory)) are caught and the final
result is the emission of this exception turned somehow into an error event.

whether or not other system call exceptions related to this IO operation
will be corralled and turned into event emissions is formally undefined
(but they probably will be).




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
sentence that we jumped over to writing [#bs-139] the perfect agent interaction
model.

so this would serve as a good prototyping ground for that.


#### the converse of the above but for the downstream will be [#here.H]

(that is, either write you output to a file (named as an argument) or to
stdout.




## the downstream IO normalization :[#here.D]


### the non-atomicity of all things :[#here.9]

when not locking (as will be explained below), it is certainly possible
that between the time when we (let's say) take the "stat" "snapshot" of
the file and when we (let's say) try to open the file that the file may
change or have been removed (or permissions may have changed so it is
not writable, and so-on). generally, between any "then" and any "now",
assume that in this interim literally about the state of the filesystem
may have changed.

there may be multiple places with similar such issues here and in the
sibling nodes.

the existing logic may or may not account for that, but at least we
have it corralled into one place where it "should" be, and we have it
bookmarked for the future here, and it is hopefully abstracted away enough
not to affect the sorroundiing system too much.

for code contemporary to this writing and newer, we generally try to
use locks to allay this issue. there is a "split second" (or perhaps
longer, on an overloaded system) between when you (let's assume
successfully) open a file and when you (let's assume successfully) aquire
a mutex lock on it. but in fact it's a distraction to assume this compounds
the problem. the simple fact is, either you acquire the lock or you don't,
and whether or not you had to open that file first is just a detail.




## the path-based normalizations :[#here.G]

the most commonly used features of this sidesystem (to read and write
files) is implemented by what is also the most fun and weird "game mechanic"
it exhibits:

these commonest filesystem operations are implemented as [#fi-004.5] "normal
normalizers."

this means that in the same way we might normalize a string to make sure
that it is a valid email address, we will also try to produce an open
filehandle from a string representing its path.

near the curriability of normalizations, this becomes a useful mechanic
to have. but in general, too, it is a design decision that (at its best)
"just works", sometimes even paying unexpected dividends.




### the criteria

the commonest thing that all path-based normalizations have is that they
all operate on a single path argument when executing. they may recognize
other arguments as well, but always this one (and probably only this one)
is common to all of them.




### our states

experimentally we model these normalizations as having three states:

  1) being constructed/edited
  2) frozen as curry
  3) being applied

all actors in the subject category will assume states (1) and (3),
but not all will necessarily hit (2).

during (1) and (3), the implementing actor object is necessarily
mutable. when (2) it is necessarily frozen.





## :#note-01

we opt to have this feature ivar (which is used in perhaps only two
sub-classes) defined in this base class rather than the other
alternatives but note that it is not used by all child classes.
_
