# the mock system narrative :[#023]

## introduction

from the highest level this whole mock system thing can be broken into two
parts: the kind of crazy part and the really crazy part.

the kind of crazy part is the fact that we store dumps of stdout, stderr
and the exit code to a hand-written CSV-like 'database' and the filesystem;
in order to mock the system responses for particular system calls. this part
actually isn't that crazy.


### the really crazy part lays below this top node,

that is where the madness begins to begin. it concerns itself with maintaining
a long-running server process to deliver these system commands from the
"manifest" to shell scripts being run to build the fixtures. there is a rough
introduction to that whole scope over at [#018] the system call fixtures
server.

the significance to us here is that (of course) the same logic for reading
from the manifest will be used when in "playback" mode and in "record" mode
(which itself needs some "playback", because while each command's stdout,
stderr and exit code come from the real-life system call (at least, that
is the plan); the commands themselves begin life (currently) as records in
the manifest file.)

but we don't want the "recording" facilities to make noiser this node, whose
primary function is to playback when running our tests, and not to record
which is a relatively less frequent (but still important!) activity. hence
you will see traces of recording apparatus but hopefully not big pieces of it
here.

the following storypoints will try to clarify in-situ as such issues come up.



## :#storypoint-45 :#what-do-you-mean-by-IO

the terminology here is guaranteed to change. but for now:

  • 'fixture' here generally means a "physical" file that contains a dump
     of stdout or stderr.
  • 'manifest' refers to both a particular kind of "physical" file and the
     more abstract notion of the data it contains. the data it contains is
     a collection of entries:
  • 'entry' refers to one item in the manifest. for now these are always
     particular system commands, but we reserve the right to broaden this.

ultimately the point of all these (on the surface) is to mock the system
(in albeit the most ridiculously overblown way imaginable). we can refer
to this as "playback", since it's playing back the "recordings" we have
in our manifest and the fixtures it points to.

the way we implement this is that in our application code we restrict ourselves
to interaction with the system solely thru `Open3.popen` (that is, no
backticks, certainly no `exec`, to the extent that we want to write testable
code, which you will see will not always apply to code that tests code..)

to make things more abtract and less coupled to certain libraries, we refer
to `Open3` as a "system conduit". and all we know from the perspective of
our application code is that we interact with the system through this
"system conduit", which as far as we know only has this one method called
`popen3`.

this relatively small abstraction and internal API choice has had a hugely
positive impact on not only the testability but the general architecture of
our application code. so here's the rub:

application-wide we should only ever reference `Open3` once, and that is a
place where we set the system conduit. this same system conduit will then
get distributed downward all throughout the application tree as it is built.
when we run our tests, we swap-in a "playback" system conduit instead
of using `Open3`. for anyone familiar with 'web mock', it is exactly the
same principle here.

if you recall from the intro the "really crazy part", with these same
entries in our manifest, before we use them to write tests around, we need
to issue them to the real live system and record the responses.

when we are engaging in this process, the class we use to model the system
command we are now referring to as a "handle". (the term is borrowed from
the idea of an IO filehandle; that is, a thing that be read from and
written to.)

however, when we are running our tests we have a quite different scope of
responsibility for the entries in our system manifest: they need to act
like the our system conduit. hence we call them a "mock system conduit".

and as you might imagine, although these two different concerns are, well,
different, at the core they model the same data (and just implement different
behavior) so for now we have a class hierarchy with one base class and two
subclasses. this base class we annoyingly call an 'IO' (again the analogy),
but this should go away.

we might actually merge these two child classes back into one class because
of how small they are..
