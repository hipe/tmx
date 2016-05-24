# A-B partitioning :[#005]

## general introduction

the "A-B partitioner" is an abstraction created without intent of
re-use. it exists merely to help us divide up our "blocking"
algorithm into more and less interesting parts so it is easier to
understand and work with.

the subject takes as input two streams and produces as output a stream
of "chunks". each chunk is generally a grouping of contiguous "spans"
from one or the other of the two streams. what we do when spans overlap
with each other is the focus of the subject.




## introduction to theory

the subject works over a "discrete 1-dimensional vector space" (like a
matrix of pixels, but only one axis), and involves two streams each of
which produces "spans" that lie on that vector space. each span occupies
one or more cels in the vector space. ([#010]:A challenges this langauge.)

the two streams are referred to as the "A stream" and the "B stream",
and are given treatment that is intended to be fully indifferent; that
is 'A' and 'B' are arbitrary labels, and there is no built-in precedence
ever given to one over the other. (however, when no other indication is
available, it should be assumed that 'A' was the left and 'B' was the
right term when a comparison was made.)

the subject facilitates a sort of complex map-reduce for the two
streams, where generally they are "partitioned" into chunks of
contiguity when one stream has placement apart from the other:


    A . A . A A . . . . . . .
                               => [ A, A, AA ], [ BB, B ]   ( 2 chunks )
    . . . . . . . B B . B . .

    (three spans from A, then two spans from B)



    . A A . . A . . . . . . .
                               => [ AA ],[ BB ],[ A ],[ B ] ( 4 chunks )
    . . . B B . B . . . . . .

    (alternating spans of A then B)



but more interesting are the cases where spans overlap:

    . A A . . A . . . . . . .
                                =>  ?
    . . B . B B . . . . . . .


these are cases where "developer intervention" is required. the subject,
then, is based entirely around facilitating the expression of rules that
model the behavior to be effected in these cases.




## categorizing overlap

the bulk and brunt of the subject involves modeling the different
categories of intersection (which we will from now on refer to as
"overlap"). we describe the various categories of overlap with names
based on the "physical" properties of the overlap as suggested by
these schematic illustrations:

    . . A A . .    "same"
    . . B B . .

    . . A A . .    "A-skewed" (or B)
    . . . B B .

    . A A A . .    "A-jutting" (or B)
    . . B B . .

    . . A A A .    "A-lagging" (or B)
    . . B B . .

    . A A A A .    "A-enveloping" (or B)
    . . B B . .

so there are five shapes, four of which are asymmetric and so have one
counterpart for each of A and B. this permutes out to the nine (9)
categories of shape for overlap as expressed (tersely) by the table above.

every asymmetric shape has two variants, one for "A" and one for "B".
whichever span ("A" or "B") is suggested by the name we refer to as the
"reference span". (in all the above examples of asymmetric shapes we
have show the "A-" variety. to see the "B-" variants you would simply
substitute all A's for B's and all B's for A's (approrpiately).)

we use this "reference-ness" solely for the need of having some naming
conventions behind the shape categories. the rationale behind it is mostly
arbitrary, so it should not be assumed with any certainty that whichever
span is the "reference" span in a given overlap is more dominant, important,
or prioritized over the other in any business sense for the application.
such things are for you to decide when you use this library.

we will explain a mnemonic but first note that there are exceptions to
it which we will exhaust immediately following. the mnemoic is that
whichever span is "longer" (or "first") is probably the reference span.

this mnemonic holds as always true for the "jutting", "lagging", and
"enveloping" shapes: in "X-jutting", "X" is always longer and so on for
the six permutations here.

note that "same" is symmetric (it looks the same forwards and backwards),
and is the only such shape with this property. as such there is no "A-"
or "B-" variants of this shape (and in accord with the above mnemonic,
neither span is ever longer; they are always the same length).

there is no relationship between the "skewed" shape and which span is
longer. in this shape, the reference span is whichever span started
first. here is an example of an "A-skewed" where the "B" is longer:

            . . A A A . . .
            . . . B B B B .





### detail of overlap categorization & proof of comprehension

to be complete, we can offer a psuedo-proof to ourselves that we have
not left any possible category unnamed:

first, we will have to accept as axiomatic this: that in our discrete
vector space, any given cel on the vector space in relation to any other
(or the same) cel in this space has one and only one relationship to
that other cel from this (exhaustive) set or relationships: it can be
the *early*, the *same*, or *late* relative to the other cel.

we then apply this category system to the four cels that define the two
spans we are comparing by comparing the counterparts to each other:
beginning to beginning and end to end.

that is, each beginning and end of each span is either *early*, the
*same*, or *late* relative to its counterpart in the other span.

our proof of comprehension, then, is asserted to the extent that each
permutation of { early | same | late } ^ 2 is represented here:


    . . A A . .    same, same               "same"
    . . B B . .

    . . A A . .    early, early             "A-skewed" (or B)
    . . . B B .    (late, late)

    . A A A . .    early, same              "A-jutting" (or B)
    . . B B . .    (late, same)

    . . A A A .    same, late               "A-lagging" (or B)
    . . B B . .    (same, early)

    . A A A A .    early, late              "A-enveloping" (or B)
    . . B B . .    (late, early)




## categories of relationship other than overlap

we then expand our system to model two kinds of spatial relationship other
than the (exhaustive) categories of overlap defined above (because these
non-overlap relationships are also logically useful to us). they are:

    . A A . .
    . . . B B   "A kissing" (or B)

    A A . . .
    . . . B B   "A cleanly apart" (or B)

for now we do not present a pseudo-proof of comprehension for these
additional relationships. but note that we can differentiate the two by
saying that the width of "gap" between the end of the one span and the
beginning of the other is zero for the one and nonzero for the other.

(note we stay "cleanly apart" and NEVER say just "apart" because the
latter might be confused with meaning merely "non-overlapping" which
would include kissing.)

in all this make 13 (thirteen) categories of space relationship that two
spans can have in such a discrete vector space.




## meta-categories of the 13

in practice we are finding that we rarey care which of the 5 core shapes
of overlap are encounted, but we *do* care about the following meta-
categories. the following comprehensive list lists comprehesively
(sic) the members of each meta-category:

    overlap (same, skewed, jutting, lagging, enveloping)

    touching (overlap, kissing)

    "cleanly apart"

    "covering":

      • "same" - A covers B and B covers A

      • "skewed" - neither side covers the other

      • "jutting/lagging/enveloping" - the reference side covers the other,
                                       but the converse is never true.


as a pseudo venn diagram:

    +-----------------------------------------
    |  all spatial relationships
    |
    |  +--------------------------------------
    |  | "touching"               • kissing
    |  |
    |  |  +-----------------------------------
    |  |  | "overlapping"
    |  |  |                       • [the above 5]
    |  |  +-----------------------------------
    |  +--------------------------------------
    |                             • "cleanly apart"
    +-----------------------------------------


corollaries

    • the relationship is "touching" IFF it is not "cleanly apart"
      (and vice-versa)




## next

the narrative successor to this is [#010] our document theory.
