# the find narrative :[#032]

(EDIT: historical! some ideas here assimilated up into [hl]'s find)

## introduction

wrap the unix system utility of the same name



        ~ the point is to make it hard to succeed ~

we are playing with a pattern here .. it's weird but i kind of like it:

internal state is totally hidden so there are no straightforward
attribute readers - NONE. This is designed such that it cannot fail.
Its methods are infallible. Every high- and low-level property can only
be queried via passing two callbacks, one that is called when the
property is valid and one that is called when it is not.

The details: the Command object is made up (either virtually or actually)
of high-level composite (derivative) properties like the command
string, and lower-level constituent properties that .. constitue it,
like e.g. the filesystem paths that will go into the command string.

At any given time each of these properties is in either a valid
or an invalid state (in fact we will probably maintain a frozen,
immutable state). The state of validity *must* be queried as
part of querying for the property - it is not possible simply to
send a message requesting the value of the property, just as one
does not simply walk in and out of mordor.

Never ever do we result in an invalid value, but as such never ever can
we deterministicly expect that a method call will always result in
a valid value. Each accessor method ("") must be able to follow one of
two paths, one when valid and one when not.

Each accessor for each property then follows a yes/no form
where it takes two corresponding callbacks as its two arguments.
If the property is in a valid state, `yes` is called (either with
a dupe of the property or with nothing, based on whether the arity
of `yes` was 1).

If the property (either because of something intrinsic or something
extrinsic in the state of the host object) is invalid, `no` will
be called, always with exactly 1 string explaining the failure reason.
