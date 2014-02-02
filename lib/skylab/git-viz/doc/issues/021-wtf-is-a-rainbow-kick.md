# wtf is a rainbow kick :[#021]

we didn't know what to call this idea so we looked up that one soccer move
where the player kicks the ball with her heel and it goes over her head from
back to the front, landing in front of here whence she can kick it again.
on one level this maneuver is an apt (if figurative) metaphor for what we are
trying to accomplish with our server here. if upon closer inspection the
analogy degrades then it is being inspected too closely.

what we are dubbing "rainbow kick" (for now) is name for the (in this universe)
as-yet not fully reified, so just partly theoretical, technique whereby one
process (perhaps a short-running process, like a script) needs some kind of
long-running process (like a server) to be running, and it isn't already
running.

the ridiculous thing we really want to work is this: the short running process
forks itself into two, and with the child process it calls exec, and exec
which either *is* or invokes (or even execs again) the long running process.
then the parent process (remember, the short-running-process) (ick) blocks
for some time to let the server start and pings it until it is started, then
once it is there, all is happy in the world.

(actually, better idea: the short-running process makes a system call to
the server-starting script. the short-running process blocks until this call
returns. the server-starting script then "daemonzes" itself by
forking: the parent returns and the child stays running in the background.
the parent returns to the original short-running process's system call,
and now the short-runner may resume assuming that the server is running EGADS!
now the only trick is to figure out how to dump stack traces to logfiles
WAHOO!)

in a distant branch more than a year ago we got this to work with our
test running facility (what we were calling a "stem server"), but it was
half baked, icky in parts, and it got really tricky to debug.. (also it's
in some branch or something, we are still working our way back to it.)

but we are older and smarter now (certainly smarter) and begin a re-approach
to this wistful flight of fancy.


## :#storypoint-15

it would be nice to be able to eliminate these arbitrary timeout values..
but how? for example, this one here, the rainbow kick operation does the
following: 1) forks 2) (child process) execs out to a zsh (the front server)
3) the zsh tweaks the environment and then execs out to ruby (the middle
server). there is considerable latency in these operations, and it will vary
from system to system how long they take. the best we may be able to do is a
degrading throttle of retries.
