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
introdcution to that whole scope over at [#018] the system call fixtures
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
