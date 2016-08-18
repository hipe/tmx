# the scanners narratives :[#049]

## introduction

a "scn" (short for "scanner") is and always will be an object that
responds to `gets` and results in a true-ish object if the scanner has
any more items to give, or false-ish if it is all out of items.

a "scn" is intentionally minimal: formally it is and always will be
defined by this one method only. see [#044] "scan" that builds on this.

this particular implementation of "scn" simply aliases the `call` method
of the Proc class to `gets`.

(point of history: this document was formerly [#ba-022] but we
gravitated the nexus of scanning up to this library because of its
growing universality.)


## background

the scanning metaphor has become favorite way to implement "producers" (or
even just to represent lists abstractly) in a general way.

we like the scanner construction because it lets us distill a huge swath of
data-structures and iteration operations down to one RISC-like minimal
standard on top of which we build back up our tools, making an even huger
variety of permuations of these operations both possible and easy.



### defined

our formal definition for "scanner" is intentionally spare, and takes its
"look and feel" from how we may get each line from an open filehandle:

• a scanner is an object that produces each next element with a call to `gets`
• a scanner indicates that it has no more objects left to yield by resulting
  in a false-ish from a call to `gets`

the fact that we use `gets` and not some other name is of course arbitrary.
(`call` and `next` were considered.) we borrow the name from ::IO because the
metaphor is such a precise fit, but bear in mind a scanner is not limited to
producing strings (the 's' in "gets"), however:

a corollary of the second point above forms one of the scanner's most
defining limitations: a scanner cannot be used to produce elements whose
valid state may include `nil` or `false`.



### scanning vs. enumerating

#### scanners are like enumerators made portable mid-iteration

in the last year or so the scanner metaphor has overtaken the comparable
Enumerator construct as the generally prefered "universal interface" for
production operations for a few reasons:

whereas the Enumerator's big value prop is that it is a list iteration made
portable, a scanner is a list iteration made portable along with its
"scan state" (that is, index of the current element if you are scanning an
array). so one part of your code can build the scanner, another part of the
code can advance it to a certain state, and a third part of the code may
do something with the rest, and so on.

with an enumerator all of this is possible, but it is not the kind of
interaction the enumerator was made for: an enumerator is like a wind-up toy:
it likes to unwind all at once, it doesn't easily stop in the middle. in order
to get only one element at a time from an enuemrator you have to call `next`
while catching a ::StopIteration, which is a show-stopping level of ugliness.

a scanner is more like a PEZ® dispenser: it was engineered to issue preciesly
one element at a time on-demand, rather than spit them out all at once.
like a PEZ dispenser it can be passed to one "person", that person can keep
taking PEZ until she is satisfied (i.e she reaches the quanitity she was
looking for, she finds the particular one she was looking for, or all the
PEZ run out); and then she can pass the dispenser on to the next appropriate
person and so on.

(to stretch the metaphor even further, the person she decides to pass the
dispenser to may itself be determined by what particular PEZ were that the
dispenser dispensed! but that's crazy talk.)



#### a scanner may be more efficient

this is not the primary reason we use them when we do, but [#bm-011] scanning
is more efficient than enumeraing for some operations, operations that often
describe our use case.

this is probably just because of the way we typically use them: an iteration
over an enumerator is usually done with something like `each`, a method that
creates one call frame for each iteration. whereas, iteration over a scanner
is usally done with sommething like `while`, which does not create its own
call frame.



#### a scanner is not a general replacement for an enumerator.

as sugested above, the set of all lists that a scanner may represent is a
subset of the set of all lists that an enumerator may represent because of the
semantic overloading we apply to the result value of `gets` (namely, when it
is false-ish it is a control-flow boolean, when it is true-ish it is both a
control-flow boolean and a business value).

although the reverse is not necessarily true, any scanner may be translated
to an enumerator regularly (simply: your body of the enumerator is a while
loop iterating over your scanner, and pass each element to the yeilder).

enumerators are still good for all the things that they are good for, so
don't use a scanner when an enumerator is a better fit. our point in this
article is just to say that the scanner is a better choice for a universal
way to model iteration, for the kinds of iterating we generally do.