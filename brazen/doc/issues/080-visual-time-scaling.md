# the scale time algorithm :[#080]

## table of contents

  - introduction [#here.b]
  - into to scale adapters [#here.c]
  - a linked list of adapters [#here.c]
  - width units [#here.e]
  - what about vertical space? [#here.f]
  - blocking presented through examples [#here.G]
  - general algorithm (and presentation of "bidding") [#here.h]
  - accurate projection [#here.i]
  - once a scale adapter has been resolved [#here.j]
  - adding new scale adapters ("subjects") [#here.k]
  - cons of scaling [#here.l]




## introduction [#here.b]

this algorithm is concerned with maximizing dynamically the amount of
information that is conveyed within a fixed horizontal space. as such
it is :+[#hu-001] a form of summarization (by some .. ahem ..  stretch).




## introduction to "scale adapters" & general concepts [#here.c]

we attempt to effect the above objective through the use of an ad-hoc
concept we construct here that we experimentally call a "scale adapter".
within this document we will sometimes refer to this concept as the
"subject" or "subjects" as appropriate, to insulates somewhat this
document's deep concepts from its surface names.

we will hand-write a flexible N number of subjects, one for each scale
of time that we wish to render within. hopefully adding new subjects will
be mostly painless, as will be illustrated below.

each subject has a "block size": the block size of each particular
block will correspond to some probably natural demarcation of time,
for example "year", "2-week", "day" etc.

all of the concepts glossed over above will be presented in depth below.




## a linked-list of adapters [#here.d]

the subjects will be placed into an architecture somewhat like that of
plugins, but also like a linked list: it will be required of each
subject to know what is the next subject with the next larger block
size. each one subject will "point to" the next subject with the next
larger block size, probably through the use of a symbolic
representation of the subject's class name.

a best-fit subject will be resolved by starting with the subject with
the smallest block-size and seeing if it can express the business data
within the alloted width. if not, we will try the next subject that
the subject points to (which we assume must have the next larger block
size).

this process is repeated until the first winning subject is found.




## "width units" [#here.e]

we conceptualize horizontal screen real-estate as width "units" - units
can be conceptualized of as monospaced cels in a table, as character
columns in a terminal screen, or even as pixels. their specific form,
however, is incosequential. what matters is:

  1) width "units" (whatever "unit" means) are the currency that the
     subjects deal in when they determine whether they can render within
     a certain width.

  2) width units are indivisible. when we pass such units back and forth
     as arguments or results we will always count them as integers, and
     never deal with fractions of a unit of width.

  3) a negative width is meaningless here.

  4) a width of zero means no screen real-estate at all. given no
     screen real estate, it is not possible to express anything
     visually. given this, dealing with the zero-width case is never
     interesting as it gives the subject literally no room to effect
     any noticable behavior. given *this*, we don't deal with
     the zero-width case here. at some high level, given such widths
     we may either normalize them to `1`, raise exceptions or perhaps
     leave the behavior undefined.

the synthesis of the above is that width units will always be non-zero,
positive integers (except in places where we deal with effecting this
selfsame maxim).




## (what about vertical space?) [#here.f]

currently we conceive of the veritcal dimension as being outside of the
scope of this libray node. in practice (and at this moment), the vertical
dimension (in contrast to the horizontal) is filled with business
content of arbitrary volume; and is treated as being limitless. but
this is subject to change and is outside of our scope.

and yes, "horizontal" is only a label. it is conceivable that some front
client uses the horizontal and vertical dimensions for the opposite
semantics that we assume here. "horizontal" here is a label for any
arbitrary dimension of visual space.

(however, given our current approach to rendering headers, flipping the
horizontal and veritcal may be nontrivial.)




## "blocking" presented through examples [#here.G]

imagine we are looking at a day-planner that has squares (cels/
slots/blocks) for hour blocks of time (1:00pm, 2:00pm, etc).

imagine your span of time is from 3:55 to 4:05.

when rendering these spans of time to screen, we "snap to" full
blocks of time (because as it works out we use "screen tiles" to
represent blocks one for one as we explore below).

so for 3:55 to 4:05, we need to occupy every block on screen
that this span of time overlaps with, so the whole 3:00 block
*and* the whole 4:00 block. note that this span of time needs
two hour-blocks to render even though it is only 10 minutes long.

contrast this with 3:05 to 3:55, which only needs to occupy one
block of time, although this duration is actually longer than
the previous example (50 minutes, up from 10).

in effect you have to "pay for" that margin of time between when
the block starts and when your timespan starts; and then also
you have to "pay for" the right margin between when your span
ends and your last block ends.

(this is exactly like if you had to rent studio space by the
hour on the hour, and you wanted it from 3:55 to 4:10: you
would need to also "pay for" the first 55 minutes of the 3:00
block and the last 50 minutees of the 4:00 block.)

now,

  - we are given the max number of screen tiles that can be used
    in our screen rendering. we need to "meet or beat" that number
    of tiles.

  - one block takes up one screen tile.

so we determine how many full blocks we would need to express the
span of time, and then see if that number of blocks is less than
or equal to the number of screen tiles available to us. this
determines whether or not we can use this level of time to express
the span in the alotted screen space.

so we need to calculate how many full blocks we will need.

for better or worse, our formula for determining how many full
blocks we overlap with is:

  - pay for the "head margin" by adding it to your span of time
    (duration)

  - pay for the "tail margin" by rounding the above number up.


so for the studio example:
  - we want from 3:55 to 4:10 (15 minutes long)
  - pay for the "head margin" (55 minutes)  15+55 = 1h10m duration
  - pay for the "tail margin" by rounding up: 1h10m->2h

for an example from earlier (for contrast):
  - we want from 3:05 to 3:55 (50 minutes long)
  - pay for the "head margin" (5 minutes) 50+5 = 55m duration
  - pay for the "tail margin" by rounding up: 55m->1h


(NOTE - the below is an old version of same. can probably EDIT most of it away)

the overaching premise of our efforts here is that the number of width
units within which we may express ourselves is given and fixed at any
moment we are trying render.

if a given subject needs more horizontal space than is available, it
cannot have it. rather, the subject may only report whether or not it
can express itself given the available width units and some sort of
expression of the time distribution of the business data (currently a
start datetime and and equal to or greater end datetime). this "bidding"
process is explained below.

a subject will "lossfully compress" the business data into a target
width by a process we call "blocking", a concept we will present
through example:

    imagine there is one business eventpoint on tuesday morning,
    and then another one on tuesday evening, and another one on
    wednesday afternoon. each of these eventpoints has an arbitrary
    "business quantity" associated with it:


        Tues. AM          Tues. PM          Wed. PM
        (bus. qty: 10)    (bus. qty: 3)     (bus. qty: 5)


    with a block size of "one day", we can end up with two blocks:


            Tuesday                 Wednedsay
            (bus. qty: 13)          (bus. qty: 5)

    note that we added up the business quantities for all events that
    fit into the "tuesday" block. in the same way we can effect this
    summarization to a greater degree if we increase the block size:

    with a block size of "one week", we can end up with only one block:

                         (The Week)
                         (bus. qty 18)

    when the business data is effectivly a sparse matrix with time on
    one axis ( and business item on the other axis, here we present
    presumably only one time with differing values for "business
    quantity" over time ); with such a matrix and the use of "blocking"
    we can expand and collapse how the data is presented, with a savings
    in horizontal real estate that comes at a cost of detail (which is a
    good general description of :+[#hu-001] summarization).


for ease of implemetation at this early stage:

   - all "blocks" from first to last for a given input will
     produce visual representation. (that is, they will all be shown on
     screen)

   - even blocks with nothing in them (or the empty space where a
     block would be, as it may be implemented) will have visual
     represntation.

   - the amount of horizontal real estate given to each block will be
     the same amount, regardless of which block (or from which adater)
     it is.

   - the amount of screen real estate given to each block is currently
     fixed: it is 1 unit of width.

   - currently we will not deal with thinking about any visual
     decorative separation between blocks; i.e. the space between
     adjacent blocks is 0 width (but if this changes its impact on the
     algorithm should be regular).




the implementation of the algorithm is then concerned with how we define
blocks and how we determine which block each business entity falls into.

important details include handling the sparseness of blocks.




## general algorithm (and presentation of "bidding") [#here.h]

what is given is:

  • the width available to us to render within in discrete integer
    units. assume this width is 1 or greater.

  • "rows" of content as a sparse matrix of business units.

  • two datetimes: one representing the date of the earliest business
    event, and that of the most recent event.

we resolve exactly one "scale adapter" through a means we call
"the bidding process":

  • we create one frozen structure we call the "request for quote"
    that encapsulates the relevant state of the given input:
    start datetime, end datetme, available width.

  - starting with the scale adapter with the smallest block,
    ask it to "bid" on this "request for quote."

    • if it results in a bid, this means that the subject can
      render the business content within the alotted constraints.
      we are done.

    • otherwise, move to the next scale adapter and try again.
      (i.e repeat the previous bullet). at this point (if the rest of
      the algorithm holds) there will never not be another scale adapter
      (see below).

    all other things being equal, this approach finds the "best fit"
    by finding the subject with the smallest block-size that can
    still fit "everything" on the screen.

  • we will arrange it so this process cannot fail. (there will be
    a base case subject that can render any input at a width of 1,
    and per a note above the available width will always be at least 1.)




## accurate projection [#here.i]

"projection" is an important detail of the bidding process. through
projection the subject must determines accurately whether or not it can
effect expression within the given the constraints.

with our normal ratio that expresses "how big" our blocks are
(currently we measure this in "days per block"), through simple
arithmetic with certainty we can eliminate subjects from the running
with a straightforward test:

given our "days per block" as a rational number, and given the timespan
amount from earliest event to last event as another rational number
("amount of days"), we can determine at a minimum what fractions of
blocks we would need to render the data:

  amount of days / days per block = amount of blocks

we do not deal in fractions of a block so we always take the ceiling of
this rational number to get a crude estimate of the minimum number of
blocks that will be needed. (elsewhere below we will refer to this term
as "N".)

consdier:


      Thursday PM         Monday AM *not* the next week but the week after
      (bus. qty: P)       (bus. qty: Q)


the "time distance" here is something like 10.5 days. now, with our
"rough estimate" formula above, and with a block size of one week,
we come up with needing what we think is 2 blocks:


    10.5 days / 7 days per block = ~ 1.5 blocks -> 2 blocks


*however* in practice this figure is imprecise and in some cases (half?)
it is incorrect, and it is for this reason: block demarcations occur at
fixed points with respect to real time. where the block demarcations
occur is not determined by the business eventpoints.

so, the number of blocks necessary is determined by this: drawing a
"line" from first business eventpoint to last, how many blocks does it
touch?

the same "distance" of time will occupy either N or N+1 blocks based on
where it falls into the fixed "ether" of time:

consider a block size of "one day", and business events that span (in
this example for less than a day):


               | <-- e --> |

     sunday  |    monday    |   tuesday   |   wednesday


in the above case, the business events start and stop in the same day,
so we only need one block. however if the same "time distance" happens
but starts slightly later:


                   | <-- e --> |

     sunday  |    monday    |   tuesday   |   wednesday

then we need two blocks. (we will refer to this as "example P" below.)


for another example, if the first eventpoint is in mid-december and the
last one is in mid-january, if our block size is "one year" we need two
blocks (two years) to render this, even though the "time distance" is
only about one month wide ( 1/12th of a block ). (we will refer to this
as "example Q").

so to get an accurate projection of how many blocks we need, we try
this:

  A) how "shy" is this timespan from being a discrete (whole) number of
     blocks long?

     if blocksize is 1 hour and the timespan is 1.75 hours, it is .25
     hours "shy" from the next largest whole block length.

  B) at what "offset" does this timespan start, with respect to the
     block it starts in?

     if block demarcations fall cleanly on the hour, and the timespan
     starts at 20 minutes after the hour, we say the "offset" is 20
     minutes, or (1/3) of an hour.

whether this "offset" term from A is greater than the "shyness"
term from B determines whether or not we will need N+1 or N blocks.




### let's try it on example "P"

so let's try this on example "P" from above (let's start with the first
of two):

how "shy" is the timespan "e" from the block size (1 day)? let's say
it's 6 hours shy of being a full day (so it's exactly 18 hours long).

at what offset (with respect to the block) does the timespan start?
let's say that in that first case, it starts at 5 am ( 5 hours ).

so the "offset" value 5 hours, and the "shyness" value is 6 hours.
the offset is less than the shyness, so we stay at N and do not "spill
over" to N+1 blocks.

but as soon as the "offset" meets or exceeds the "shyness", we bump up
to N+1 blocks.




### let's try it on example "Q"

from mid-december to mid-january is 11 months shy of a year (so our
shyness value is (11/12) of a block (blocks are years for the example
adapter)).

and our thing starts mid-december, so our offset value is (11.5/12)
(or (23/24) if you prefer).

our offset (11.5/12) is greater than (or equal to) our shyness value
(11/12), so the spillover happens. the number of blocks necessary is
N+1, or two blocks.  whew!




## once a scale adapter has been resolved [#here.j]

now we have resolved the one subject we will use to do the rendering.
we now execute :#the-rasterization-process:

  • :#pre-render:

    • row by row and then cel by cel of the sparse matrix of content,

      - within each row you will maintain a "block box".
        with each data cel in this row, determine the appropriate
        block its value will be added to.

      • add the business value to the "sum" we are maintaining in this
        block.


  • :#mid-render:

    • with your "aggregated cels" in your block boxes (one box for
      each row), build a "statistics" (just an array of the values,
      non-unique and sorted).

    • use this "statistics" to bake your [#026] glyph mapper.




## adding new scale adapters ("subjects") [#here.k]

for normal cases you should need to touch 2 files: the one you are
adding and the one that comes before it. the one that comes before it
must have its pointer changed so it points at you now. and what it used
to point at will become what you point at now.




## cons of scaling [#here.l]

"common scale adapters" "scale", which is perhaps a misnomer: they
maintain a direct relationship between linear time and visual space.
one unit of visual space over here will represent the same amount of
time as that same unit of space does over there.

(remember the variation between the various scale adapters manifests
primarily in their "exchange rate" - how many units of time they fit
into one unit of space.)

using a scale adapter can be good for presenting possible patterns as they
may relate to real time, but it does so at the expense of what may be
considered "wasted space", where visual real-estate is given to "long"
spans of time where "nothing" happens.

• we may resurrect what we are now calling the "solid" adapter, which
  does no time stretching or squashing at all, which effectively gives
  each commit event its own column (which we would call "block" if we
  were blocking).

  (if we bring this back we will enjoy the challenge of rendering
   headers in an optimaly expressive way)

• one day we might explore this vapor-ware idea of an "ellipsifying"
  adapter, as perhaps a behavior option for the time scale adapters.
_
