# the flex2treetop narrative

## :#storypoint-210

this is headless's experimental new spin on [#fa-013] "meta-fields" (or
"meta-parameters") (and not to be confused with its old spin on this, dating
from late 2012). as this works and takes shape we will document it over there.
for now it is a #frontier-hack.

and then a year later it moved to [cb] and became a clean ground-up
re-write of a middleground between very simple actors and very complex
entites.


## :#note-320

ya know it's funny i really gotta tell ya somethin', we hate writing
and re-writing this same kind of normalization logic for every
application (nil out ivars, apply defaults, whine about missing
requireds), but the alternative (so far) has been the bloated and obtuse
[cb] enitity property hooks API. hand-writing these 20 lines each time
may just be worth the cost savings.

also we could just push this method itself upwards..




## :#storypoint-250

in this application the sole way that an action may access any method of
the service or session is through the "client" façade. this is to future-proof
the whole thing, so we have a clear, "pure-interface" layer that shows us what
the action needs from the surrounding system so that changes that must occur
in the future from the outside-in need with regards to these structures be
limited only to this node; because we are not sure what the future holds for
these structures of "service" and "session".



## :#storypoint-315

this is a "frontier hack": we subclassed the parameter class and customized
it, but when we comprehend over our parameters, the parameters we inherit
from the headless API library are still the old kind and are not aware of
the new metaparameter we added, hence when we check for the meta-parameter
value the old parameters will not respond to that method. what we are doing
here is rewriting those (~threee) parameters but this time with the new
parameter class. note we are not passing meta-parameter values to those
parameters, hence they get the defaults. this "should" work provided our
default metaparameter values line up with the parameters we int



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
