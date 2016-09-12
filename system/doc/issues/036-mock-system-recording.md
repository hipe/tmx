# mock system recording :[#036]

## objective & scope

the subject is meant to help produce a fixture file from a real live
system interaction.




## intro

blind rewrite. by "system" we mean "responds to `popen3`". by
"process" we mean "the tuple of the four resources produced by
`popen3`". the subject is a mux-mapping proxy that stands in front
of a real system (one of its construction arguments), in effect
eavesdropping on the throughput of the process from the real system
back to the client. (we do no proxying/recording at all of stdin.)

the client should be unaffected by the presence of the subject
(to the extent that our proxy classes are complete; they are not,
however they are sufficient for our use cases). however, with
each read that the client makes of the process (actually our proxies)
the subject also does this:

it writes (to the other construction argument) platform code
fragments that approximate the code for a startingpoint of a fixture file.




## the stream-based expression engine

we can implement this relatively easily as a direct, line-by-line
passthru mapping of the througput from real system to real client
if we make the assumption that the various components of the process
(sout, serr, exitstatus) are read from in a particular order relative
to each other. these assumptions are enforced internally by a state
machine, one that will case the recording to fail loudly when assumptions
are not met.




## the cache-based expression engine

for more complex, concurrent system interactions, the above strategy
can fall over. when multiple processes will be open and read from
concurrently (or just in a staggered, overlapping manner) we cannot
use the simple algorithm of a line-for-line outputting to a fixture
file of what is read from the system process. instead we (here) store
all such lines in memory until the recorder receives notification that
we are done with all system interactions. only then does it flush the
rendering of the fixture code.

this will store *all* of the lines read from the system *in memory*
to work. if this won't scale to the (weirdly large) system interaction
you are recording, look at our older cousin recorders, like:

  - look at [#037] the snippet-based recorder.

  - look at [#038] the legacy recorder that uses OGDL.

if any of the above see any future utility, they should probably be
refactored to become an "expression engine" for our new recording
architecture.
