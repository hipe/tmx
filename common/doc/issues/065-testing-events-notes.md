# testing events notes :[#065]



## local idioms: "handler" vs "listener" :#note-7

reminder: as local idioms, "listener" and "handler" are almost the
same: both receive a list of symbols (the "channel"), and both
typically use the block parameter which is a means to produce or
effect the emission payload or side-effect (e.g event or expression
as appropriate for the emission).

the difference here is that a "handler" *must* accept one positional
parameter which will be the "channel" in the form of an array of
symbols; whereas the "listener" receives this same channel but spread
across all its positional arguments (so typically a listern has a
single "glob" parameter).

we prefer using handlers internally because of the memory savings that
is realized by using the same channel; but we prefer the "listener"
form when it is actually being used to receive an emission that is
written as code inline in some business space (because of readability
and ergonomics).




## :#note-5

as well as being the underlying workhorse behind most of this library,
the subject is also available to clients to be used as a standalone
testing insturment in its own right.

the subject is for recording the emissions that occur during
(typically) the operation under test, and then subsequenty exposing
those emissions for reading in a variety of ways. essentially it's
just a selective emission listener (proc) bundled alongside a queue
(array) that gets written to with an emission structure derived from
each emission sent to that listener; but to in order to assert sane
usage and sensible test design, the user may want to know about its
underlying state-based mechanic:

the event log is always in exactly one of these states (i.e modes):

    option-time  ->  record-time  ->  read-time  ->  closed

it starts in the state on the left and at any point it can transition
(internally) to each next state through the transitions proscribed by
the arrows; i.e once it has left a state it cannot go back.

every exposed method is associated with exactly one of these states.
when any such method is called, if the current state is not the
requisite state but is "accessible", the state will be transitioned
forwards as necessary. trying to call a method that is associated
with a previous state is guaranteed to fail loudly.

this used to be function soup (see tombstone).



### :#note-6

we could do the thing with a hash that associates states with
offsets and and array of transition methods, and call each
necessary method but that's just barely overkill yet..




## a hierarchy of checks  :note-A

broadly we can categorize the checks we make here into two: there are
those that relate to the taxonomy (classification) of the event (to the
extent that this concept is baked into our API), and there are those
checks that relate to the structure of the specific event [class].

taxonomic checks include those about the "trilene" (is it OK, not OK or
neutral?) and those about the "channel" (the channel being represented
as an array of symbols).

structural checks are those about the particular members (both formal
and actual [#fi-025]) of the particular event.

in practice, whenever any of the checks (where assertions exist for that
category) fail from the former category, any checks from assertions from
the latter category likely to fail also.

whatever the reason for this is is an answer to an interesting question,
but it is decidedly outside of this scope. it is like asking why it is that
two books with different titles are likely to have different words..

in fact this premise may be flawed - it may be that in practice we are
just as likely to change the taxonomic classification of an event and
keep the same event class as not, in which case our justification is
flawed. however we can reach the same conclusion under a different
justification:

our assumption is that when any of the more essential checks (those from
the former category) fail, it is almost certain that the (any) subsequent
checks below will also fail. (or not, as postulated in the previous
paragraph.)

we assume the user knows this so in such cases you will see we skip some/
all of the (any) below checks towards improving the [#hu-044] "relevance
density" of the expression failure (i.e reducing the noise).

regardless of how correct the uncertain premise is, the behavior is
nonetheless desireable to the extent that we prefer a more summarized
failure message to a longer one for any given single failing test. whew!




## we assume that this ivar is intialized because.. (:#note-B)

we assume that under typical oldschool usage the system-under-test API (or
similar) was called with the event handler proc that came from the event
log; ergo we assume that the event log ivar is initialized.

using just `gets` allows the client to swap-in an ordinary [co]
stream for the event log for more modern usage (experimentally).




## about this legacy, oldschool section :note-C


the below block is what remains of the oldschool stream-oriented
assertion methods. their bodies have been replaced with logic to bridge
to the newschool peterite- (i.e "matcher") oriented approach.

the received indentation of the block has been preserved (and some other
formatting added) so that each still-intact method from this legacy section
will have a declaration line that is identical to (and reaches back to)
the received line through the VCS.




## :"future expect vs. expect event"

(this is written on the subject of "future expect")

NOTE - this is "almost" deprecated but not quite: this was written as
an experimental simplification and re-conception of "expect event"
(but before "expect event" has its own excellent rewrite). the
experiment was (and still is) this:

  "what if we queue-up a list of expectations *first*, and then
   run the test case? as each emission occurs, shift an expectation
   off the queue and compare it then and there."

this way, as soon as an expectation fails we can inspect the state
of the SUT at that moment; as opposed to "expect event" which uses
two other alroithms, the latter of which is:

our favorite way to test emissions now is to run the whole test case
first, then store all the emissions into a memoized structure that
is shared across tests. each test tests a small part of the set of
emissions. this leads to better faster smaller tests at the cost of
not being able to do the thing explained in the previous paragraph.

but because this is still an interesting question, we are keeping
this around for now. but it bears mentioning that at writing it is
used in only two test files (both in [br]).

simplify event testing and (with "future") get immediate response

(previously:)

NOTE - before you do any feature adding or maintence to this file,
look for ways to integrate it with 'expect-event'. as it is, it is
so minimal that we have left it separate. but since its inception
we have overhauled "expect event" so it is now fresher than this.
(and there is certainly conceptual redundancy between the two.)




## :#note-4 - about the newschool reification of expression emissions

the earliest incarnation of this library had a bias towards events
over emissions. as such the old way was that when an emission was
encountered, it was "upgraded" to look like an event for the
purposes of testing. for better or worse, we're preserving that
behavior for back-compatibility for now.

the "new way" is that emissions are simply flushed into lines
use some expression agent, and it is those lines (not a pseudo-
event) that get passed to our little assertion block.

this way feels more ergonomic to write tests for, but keep in mind
these tradeoffs: 1) reifying the emission in this way means that
other tests that test over the emission cannot reify it another way.
(in practice this is never a problem - emissions are really just lines
waiting to be rendered, so when you test them you are usually just
testing over the produced lines and nothing else; even if testing occurs
on one emission across different tests.)

relatedly, the particular expression agent used here will leave its mark
on the baked-in lines. 2) your test code will now have the added
fragility of assuming this shape for this event. also probably not that
big a deal in practice, when we consider how frequently it is that we
convert an emission from one shape to another (rarely) times how many
tests per emission we usually have (few).
