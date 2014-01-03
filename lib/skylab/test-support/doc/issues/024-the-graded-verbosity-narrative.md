# the graded verbosity narrative :[#024]


## :#storypoint-5 introduction

the verbosity object created by this node is itself a module - it is intended
to be an immutable constant that is shared accross your application. (it is a
module because it is generally associated with another constant: something
like a static Conf module for your application, and it generates one or more
modules, and as such it is useful to store these modules under it. :[#fa-032])



## :#storypoint-115

actually normalize x. 3 things: 1) to report the validation articulations
below, we build a one-off valid vtuple and use *its* snitch! (for grease) 2)
we don't report re. setting a default below but we could and 3) be ready for
one day revealing the below articulation.



## :#storypoint-195

"make snitch" - (formerly `sc` for "sub-client")
quick and dirty proof of concept, will almost certainly change. the idea is a
simpler alternative to pub-sub. what if you could throw one listener around
throughout your graph? the listener is like a golden snitch. no it isn't.
:~[#fa-051]



## :#storypoint-200

the snitch itself is technically "immutable" but it just closes around the
vtuple and relies on the vtuple as the datastore. if the vtuple changes its
state (in terms of its category values, not its categories!) the snitch will
act accordingly.



## :#storypoint-225

if we are at or above verbosity threshhold `i` then invoke proc `p` and send
its output to the `puts` function. in other words, conditionally say
something. passing the rendering as a proc is useful because in cases where we
wouldn't output the resuling string anyway, we save the overhead of building
it. your expression proc will be executed in the context of your expression
agent (if any) that you build the snitch with, which allows for dynamic
styling of expressions where desired.
