# the help renderer narrative :[#004]


## introduction

with few exceptions the last umteen implementations of this kind of
thing either over- or under-abstracted it. either we had a client base
class with dozens and dozens of little rendering functions for all the
things necessary to make a help screen and all the other usual
interjections; or we had things like argument and option classes.

perhaps this is a reasonable middle-ground that extensible without being
overwrought.


## persistence of the help renderer

experimentally we no longer build this on-demand, but we build it once
every time for every action. this is so because (working backwards) at
any point during its execution lifecyle, the action may want to render
the officious things of help screens. the ARGV parsing-phase is where we
isomorphically infer what the options are and what the arguments are,
and build the option parser and parse the arguments.

since the help renderer will need information from this phase to render
itself (e.g it uses the option parser to determine what the switches
are to render a usage (syntax) line), and we have no way of knowing
before hand whether or not we will need it, it is easiest (for now) just
to create it always in once place as early as possible. that is
:#this-point here.
