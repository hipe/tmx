# the dependencies narrative :[#007]

## introduction

the subject node is being abstracted from its frontier client as we
write this.

[#ba-096.G] describes precisely how we arrived at this solution.




## recent history

the subject node is the result of merging the efforts behind what was
once called "pub-sub" and what was once called "strategies." although it
is arguably a smell to munge these two disparate event model-ishes
together into one library node (the former being familiar and the
latter being an implementation of "strategy pattern"), in practice we
use them together all the time; and the clincher was how tightly the
duping behavior needed to be intergated into this idea of "dependencies"
(as a dedicated collection); and how much we didn't want to build the
API for the two of these nodes to talk to the third, as it would be a
painfully early abstraction.

in premature hindsight, we are glad we made the merge. this concept of a
"dependencies tree" is become greater than the sum of its parts. it *has*
succeeded in unmuddying its frontier client.




## all about duping


### pre-introduction: why do we care about duping?

we need to solve this problem if we want to use the subject objects in
the [#sl-023] "dup and mutate" pattern, which we do. "dup and mutate" is
a powerful pattern to implement; it just so happens that it is also a
royal PITA from hunger games to do here.


### introduction & conclusion

a particularly enjoyable challenge is the question of what to do about
duping such a structure. a subject instance is rife with business
objects and associations there between and metadata about different kinds
of events. when we dup such a potentially complex structure, which parts
do we deep copy, which do we shallow copy, and other?

we have chosen the answers pragmatically (as opposed to based on
principle); and as such they are subject to change. they are these:

  • as for the "dependencies" array and its constituents, each such
    item MUST :[#.A] be frozen (i.e immutable), so it is CERTAINLY
    safe to "copy by reference" (that is, not copy, just pass by
    reference).

  • as for the "dependences" array itself, we MUST make a dup of
    this array so that on the other side of the subject dup, we have
    our own array to mutate and we do not mutate that of the original
    subject instance; should we decide to add more dependencies on this
    side of the dup. :[#.B]

  • the role and subscription boxes are similar: both represent
    dependencies via integer offset, and both use simple symbol keys.
    they consist of nothing but primitives, which are cheap and easy to
    dup deeply. this is what we want, and our "box" implementation gets us
    all the way there in one case :[#.C], and halfway there in another
    :[#.D], with the deep duping.

  • :[#.E]: the gordian knot we cut with this most recent rewrite of the
    subject comes with this decision: the subject instance "owns"
    *every* dependency instance it manages. at a particular cost, this
    decision greatly simplifies this implementation here. the cost is
    this: we cannot casually add (for example) a pub-sub listener that
    is just any old object. rather, this listener *must* be created
    *inside* the subject instance. as we write this we are seeing how
    this decision plays out in full.

    we do this super ugly looking call to `dup` with args so that we get
    argument errors for dependency classes that forget to implement
    their own `dup` (for that common case in practice when all
    dependencies should be build with some sort of "resources" or
    "client services" argument, and/or event handler proc).

    we use this `dup` name instead of some unique name of our own design
    so that in the simplest of architectures, there is no extra API of
    our own that needs to be followed.

  • :[#.F]: in this node we prefix ivars with `__volatile__` to remind
    ourselves that they are just cached/memoized values, and not
    intrinsic or essential to the identity of the subject. in this case
    the values held by the variables are procs that close around local
    variables in the scope where the procs are created. when procs like
    these are carried over the dup boundary, the bugs they create are
    NASTY.



## the argument parsing algorithm [#.G]

we have many dependencies but only one argument stream. this is the
process by which we decide which dependencies can parse which [#pa-011]
"head tokens" at each step of the parse.

the algorithm relies on these assumptions:

  • there are T dependencies owned by the given node that is
    doing the parsing.

  • some non-negative integer N of the T dependencies will be found
    that want to parse the current "head token".

  • each dependency from N can report an "arity" for its own formal
    capability of parsing this term from a known, discrete set of
    arities A that will be defined here maybe.

this is the synopsis of the algorithm:

  while there is still more input in the argument stream, resolve N.

  • if N is zero, this is or is not an argument error based on whether
    or not this is a passive parse. in either case, stop parsing.

  • if N is more than one, verify that all dependencies in N agree
    on arity. if not, this is a "verification failure", to be defined
    below.

  • if N is nonzero, create an appropriate "term" structure from the
    stream head and advance it. dispatch this term to the interested
    dependencies.

whenever we use the verb "verify" in this library, it typically
described a method that always results in NIL, and raises an exception
on verification failure.




# (reserved for "dynamic dependencies") :[#.H]
