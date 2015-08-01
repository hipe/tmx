# the parameter narrative :[#009]

## introduction

this is an ancient legacy library, transplanted at least once (from [hl]
to [fi]). this is one of the eariest parameter libraries.

included in this node is the "worst thing i've ever done",
at #storypoint-280. we intend to kill this with fire.

the fate of this node is discussed at [#001] "discussion of the [..]". be
sure to read that before investing in this at all. and then no matter what,
don't invest in this at all.




## :#storypoint-220

We must make our own procedurally-generated parameter definition class
no matter what lest we create unintentional mutations out of our
scope. If a formal_parameter_class has been indicated explicitly
otherwise, that's fine, use it as a base class here.




## :#storypoint-230

Experimentally let a formal parameter be defined as a name (symbol)
and an unordered set of zero or more properties, each defined as a
name-value pair (with Symbols for names, values as as-yet undefined.)
A parameter definition is always created in association with one host
(class or module), but in theory any existing parameter definition
should be able to be deep-copy applied over to to another host, or for
example a child class of a parent class that has parameter definitions.




## :#storypoint-280

EDIT: this is the worst thing i've ever done.

this badboy bears some explanation: so many of these method definitions
need the same variables to be in scope that it is tighter to define
them all here in this way.  Also it looks really really weird.
[#049] we're gonna shut this whole thing down and merge this in with
the way formal attributes does it.


## :[#.D]  (in situ)
