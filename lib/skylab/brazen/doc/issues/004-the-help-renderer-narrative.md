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


## the architecture that grew from the above

the work that is relflected in the below sprung from two concerns:

1) the 'branch' and 'leaf' nodes of our system should share code and
style and interface where reasonable. (originally they did not)

2) the code near help renderers and option parsing should be
compartmentaized so that it is not one giant, ungainly ball of mud.

part of the problem with 1) is that we wrote the former and the latter
months apart, so there was some un-architecting to do which will be
evident in this commit.

our efforts here towards 2) are of course a work in progress; but we
feel that current graph that introduces a few more classes is more
workable and comprehendable that what we had before.


we didn't want to take the time to make an ascii ERD just yet, and note
this is VERY MUCH a work in prgress and is experimental, but here is
something like what's going on:

### some rough definitions

the "partitions" is the thing that represents the decisions we made
about whether each property is variously an environment variable, an
option or an argument. it is useful in both directions: with it you can
render help screens, but also given property you can look it up to
determine into which (*one* for now) of the above categories it falls.

the "kernel" is an ad-hoc structure holding an inner representation of
data. because we pass the same groups of things around to different
places, it is useful to put it into this familiar "kernel" structure.

the "properties adapter": mimicing the way that "deep" actions have
"surface" "action adapters" that "collapse" down into a particular
modality, the deep properties have a surface "properties adapter" that
provides a clean-ish interface to all things related to properties as
they pertain to this particular modality.


### the dependencies

so we start from the bottom and work upwards, to make a dependency ERD:

  the help renderer needs the option parser and the kernel.
  the option parser needs the partitions.
  the expression agent needs the partitions.
  the partions (for now) are made by the kernel/properties adapter.
  the parse context needs the kernel.
  the kernel/properties adapter is made from the argv and the action adapter.
  the argv is given. the action adapter is build first.


given all of the above, but now working from the top to bottom, we end
up with a containment ERO:

  the properties adapter has a parse context
  the parse context has the kernel
  the parse context has the help renderer
  the kernel has the expression agent
  the help renderer has the option parser

there are some holes and omissions in the above and all of it is liable
to change; but this is a fair approximation of the graph as it stands
now.
