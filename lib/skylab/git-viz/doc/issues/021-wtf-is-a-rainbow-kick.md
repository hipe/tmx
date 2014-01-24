# wtf is a rainbow kick :[#021]

we didn't know what to call this idea so we looked up that one soccer move
where the player kicks the ball with her heel and it goes over her head from
back to the front, landing in front of here whence she can kick it. although
upon close inspection the metaphor may degrade, we feel that in some
figurative way it aptly describes what we are trying to accomplish.

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

(actually, better idea: the short-running process calls exec on a server-
starting script. the short-running process blocks until this call to
exec returns. the server-starting script itself that itself "daemonzes" by
forking: the parent returns and the child stays running in the background.
now the only trick is to figure out how to dump stack traces to logfiles
WAHOO!)

in a distance branch more than a year ago we got this to work with our
test running facility (what we were calling a "stem server"), but it was
half baked, icky in parts, and it got really tricky to debug.. (also it's
in some branch or something, we are still working our way back to it.)

but we are older and smarter now (certainly smarter) and begin a re-approach
to this wistful flight of fancy.
