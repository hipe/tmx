# the shutdown timer narrative :[#022]

# introduction: scope, purpose and vision

this goofy experimental feature is saddled with the hopes of one day
complimenting the [#021] rainbow kick. imagine a short-lived process that
can start a server itself, and a server that can shut itself down when it's
no longer needed. then suddenly the boundary between script and server starts
to melt away..


## fundamental cornerstones of architecture presented as narrative:

### first there was Timers

at first, no question we were sure this was a perfect use case for tarcieri's
Timers; and so at first we built a stubbed out skeleton that pretended to work,
then we rolled the Timers into it as we had always intended. but then when we
tried it, it mysteriously didn't work. this was because we weren't calling the
`wait` method on the timer group.

but when we realized that we had to block our process to run timers, we
thought: why not just manage our own threads and call 'sleep' on them? maybe
as it turns out our use case is not perfect for Timers; maybe our use case
is much more simple.

also we don't have enough experience managing our own threads yet. this will
be good training wheels for that.


### :#then-there-was-MRI

we got our heads around our almost perfectly minimal story with using a thread
for this; we realized we didn't need to manage multiple timers but just one
(implemented with a sequence of non-parallel threads). everything looked like
it was going to work but then when we ran it, the running of the thread was
interrupting our blocking read with zeromq. as in, an INTERRUPT signal was
being thrown when we were context-switching in (or out?) of our thread.

what we had hoped proved to be the case: our desired behavior works with our
desired implementation in rubinius but not in MRI! finally we have found a
reason to need it! (as if there was ever any doubt).

so there you have it. to use this plugin (which certainly is not critical to
the running of the server) you gotta use rubinius (maybe one day we'll try
it on jruby).



### :#then-there-was-issue-[#032]

so it looks like this wasn't actually working smoothly, it was just giving
the impression of working but actually causing a fatal error that made the
server exit as a side-effect! if we understand the warnings in the source
code of ffi-rzmq (in context.rb), we should not access the same context from
different threads. although this certainly sounds like a use case for
celluloid, we are waiting to introduce that until we would really understand
it.

..ok we're back. that seems to have solved it. from within the thread we
create we send a message with zeromq over to the parent thread. yes this is a
use-case for cellular..



## :#storypoint-45

although PROCEDE_ is the same value as `nil`, which one we use indicates
idiomatically (that is, to the human, not the machine) whether or not our
result value matters. and when it matters it really matters! depending on
how the parent component handles it, (and typicially it is the case that)
if the event listener results in anything true-ish it will be treated as an
error code, and often it will stop the server, or prevent it from starting!



## :#storypoint-110

the logging is kind of chatty here, but for now this feature is so specialized
and its process so shortlived that not only we can afford this, but it has
an optimal cost-benefit ratio.


## :#storypoint-130

to be complete and avoid nastiness, we want to stop any still-active timer
thread as necessary on server shutdown.

of course the shutdown timer isn't the only means by which the server can be
shutdown. and our plugin gets notified of server shutdown just the same
whether the shutdown timer itself initiated the shutdown. (it is outside the
domain of responsibility for the server to keep track of who shut it down).

so: `@do_engage` is an indication of whether the auto-shutdown facility was
employed during this server lifetime, but is not an indication of whether
we ourselves brought ourselves here. this is part of what `@is_hot` is for.
we are "hot" when we are "running." if we ourselves initiated the server
shutdown, then we immediately turn our `@is_hot` to false before we even
issue the request to shutdown so that when we get there, `@is_hot` is exactly
an indication to us of whether we should expect to find a still-active thread
here.
