# option parsing :[#015]

the "simple algorithm" we describe here is one we came up with about
three weeks ago, before we stashed a sizeable chunk of work in order
to rebuild everything on a stronger foundation (the "phase 1" of our
three phase rebuild).

then this dichotomy evolved into what we explore at [#027] formal
parameter sharing, which probably serves as a prerequisite for
this document.




## code-notes

### "our main argument is.."

our main argument is the "formal operation frame" representing the
top of a complete "selection stack". (see the stack frames file.)

note we can access frames of the stack either by treating it as a
linked list or with random access thru an array because the formal
operation holds it as the latter internally.

all of the frames below the formal operation frame make up a list
of 1-N compound frames. each of these then wraps one "ACS"
(compound) node.

(the rest is assuming no [#016] operation-specific parameters yet.)

(the rest is assuming that we are not yet doing [#017] option parsers
tailored to the parameters "selected formally" by the operations.)

each of the aforementioned compound frames has 0-N associations that
are "primitivesque" [#021].
we will hereafter refer to these associations as "atom-esque".

the aggregation of all these atom-esque associations across all these
frames constitutes the ordered set of component associations that
form the sole ingredients to build the option parser.

that is, wherever an operation is located, all of those compound
frames that are below it (on a stack where the root is the bottom)
determine the "in scope" associations that are available to the
operation and exposed by the o.p.

indexing each in-scope atom-esque association will involve:

  • adding each such record by name-symbol to a box, one intended
    side-effect of which is assertion of uniqueness of the name
    in the scope of the operation.

  • in the value added to the box, keep an index into which stack
    frame the association came from. when the optparse comes around
    with a result we will need to assign it to the right compound.




### "thoughts on availability.."

what we will attempt here w/ availability is this: we do not
determine availability at the time we build the option parser. (the
cost of this is that we run the risk of including an association that
is not actually available.)

rather, we evaluate any availability only at the time that any value
is about to be processed for the association. the gain this way is
that the options that are passed to the option parser can turn-on or
turn-off other options (in an order-sensitive way!).

note too that if an association value is expressed multiple times
in an option parser (even with for e.g "-vvv" to mean three verbose
flags), the availability is re-valuated each individual "time" the
option is invoked (where in the example it would be invoked three
indivdual times).

putting the above two points together: if for example you were crazy
you could enforce a limit on the number of times such a flag can
be used, emitting a parse error if it is breached.
_
