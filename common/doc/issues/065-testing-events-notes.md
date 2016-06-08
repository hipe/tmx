# testing events notes :[#065]




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
_
