# the kernel properties narrative :[#082]

## introduction

kernel properties is a fresh new ground-up rewrite of something we lost
in the fire: it is for modelling something like zero-config hard-coded
consts etc in your "kernel" (whatever that is), but is meant to replace
those with a mechanism designed to be modular, flexible and abstracted
enough to make it useful for:

  • testing, whereby we can add a new "properties frame" (e.g a hash)
    to just one one (frozen) properties instance to get a new instance,
    one that is suitable for use just during that invocation.

  • config files (maybe) - a config file is just another frame on the
    stack. several config files can be stacked (as is done with many
    unix utilities that cascade config files in a chain of locations,
    taking the first value found)

  • the environemnt ("ENV") - for e.g an adapter can be built for the
    environment so that arbitrary formal properties can be "overridden"
    by particular environment variables having been set.

at the time of this writing the bulk of this has not been done yet, but
the point is it could be without too much pain.




## :[#here.B]

we do some weird hackery so that our constants sit in the right place:
everything is under the 'Properties' module (namespace), but that module
(a class to boot) itself has a parent class (which has a parent class)
which we want to "live" *inside* that module. it is done for aesthetics.
if this doesn't make sense to you just know that there is a chain of
three classes, each descending from the next.

the class (perhaps unfortunately named) indicated by this note is the
parentmost class in the chain. it is an "abstract base class" that
defines methods all properties frames will be able to use as-is.




## :[#here.C]

this class (perhaps unfortunately named for now) is the second in the
chain of three classe descending from one another. this class is a
prototype candidate experiment thingy: perhaps it will be suitable to be
subclassed by other applications outside of this one, for them
themselves to make stackable config nodes.

however, since this is only an experiment practically as fresh as this
writing, we have not yet 'released it' as part of our public API, and so
it still has an intentionally ugly name.

the significant contribution of this class in the chain is that it
defines the meta-property 'memoized', which is the mechanism by which we
define *all* kernel properties for now, but perhaps will not in the
near future.
