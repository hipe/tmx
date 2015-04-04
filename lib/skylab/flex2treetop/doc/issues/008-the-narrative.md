# the flex2treetop narrative

## :#storypoint-415

this class-as-function facade does two things: one, it acts as it sounds, it
lets us interface with our #tributary-agent classes as if they were procs -
it dumbs down the interface for the caller.

two, it allow us to lazy-load the node, which in turn accomplishes two
things: one, things regress more nicely when they break; nodes that fail to
load do not bring the whole system down until they are needed, which allows
us to pintpoint the cause of the problem in our tests faster.

two, if any of the metaprogramming is a heavy lift, it too is executed only
when needed.

this achieves the same effect as balkanizing this file into many smaller
files, which we are avoiding for some reason.




## :#storypoint-515

if the parser class is defined at this point then it must be because the
parser was already loaded from a file (the debugging feature).
