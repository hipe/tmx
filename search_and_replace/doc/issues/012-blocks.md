# blocks :[#012]

## intro & background

when we refer to "the reference" below we are referring to [#010]
document theory which is the narrative precursor to this document.

figure-1 (awkardly) has the introductory text to the structures
described further here.




## axiom (by way of requirement): streamability

the software's answer to being able to scale to documents of "infinite"
size is that it never needs to represent a full document in memory all
at once: rather it effectively consumes the document as one stream and
outputs it as another.

(ideally in this model we first read from the output stream which leads
to reading from the input stream. when we reach the close of the input
stream then the output stream may close.)

as per what seems to be convention in the broader community, the "line"
is the standard currency we use both when reading from our upstream and
when presenting our output (as a downstream). as such the main players
here need to speak "line". (see the reference for our formal definition
of "line".)

(it bears mentioning a counterpoint to this: the software currently
solves the problem of multiline regex matching by reading the whole
document into memory anyway, which nullifies some of the purported
benefits of the above (but not all: at least we aren't building a
whole DOM-style tree of the entire document.))




## the mutability of lines

we should assume that for all LTS's that overlap with a match, that each
such LTS can be transformed such that it is no longer an LTS.

(in fact we can imagine exceptions to this involving a match partially
overlapping the 2-character LTS, but by ignoring these cases we reduce
complexity in a negligable way.)

given that lines are our "lingua franca" and lines are formed by LTS's,
we will have to keep in mind that some LTS's are mutable, as we will
revisit below.





## why blocks?

given the "lingua franca" of lines, when we output our final document,
we will do this by (in effect) "chunking" our stream of "throughput
atoms" on LTS's - each LTS serves to break one line and (if there are
more atoms) signify that they begin on the next line.

now, in what we imagine as being our "typical" document transformation,
we assume there are "several" matches in a document, but we also assume
that it is not the case that every line overlaps with a match. although
the software is designed to support such use cases (plausible examples:
line ending conversion, converting tabs to spaces or vice versa), we
don't want the software to have this bias built into it that such cases
are the norm.

given that a replacement of any match can add LTS's where before there
were none, and conversely when any match overlaps with an LTS, its
replacement can mutate the existing LTS; then when producing the output
for a match whose replacement is engaged we'll have to (in effect) scan
every character under the match to re-evaluate its throughput atoms (to
use language that is introduced in the next document).

because the input characters have already been delineated once (by our
line scanner that read each line of input, acting as stream "A" (or "B")
when we read the file); *and* as imagined above we're assuming that not
all lines overlap with matches, *then* we say that when assembling the
output, it's generally wasteful to re-delineate over every character of
the document, when in fact some (and "usually" most) lines remain
unchanged.

our answer to this is to break the document up into "blocks" (where a
block is a span of one or more contiguous lines): each block is either a
"matches" block or a "static" block. as the name suggests, a static block
cannot change during a transformation, and as such we never need to
re-scan it; it is only the "matches" blocks that can be transformed.

the next section goes into detail about this design.




## how is the document represented as blocks formally?

as introduced in the previous section, we represent the document
entirely by partitioning it into "blocks" (either static or "matches").

the document:

  • is composed solely of these blocks
  • can start with either kind of block
  • must have at least one matches block
  • must alternate between type of block
    (i.e can never have two contiguous blocks of the same kind)

given the above constraints, these are some examples of entire documents
represented in terms of what kinds of blocks they partition into (where "M"
is for matches block and "S" is for static block):

    M, SM, MS, SMS, MSMSMS..

with no proof, this seems to be the "pattern": `S? M ( S M )* S?`.

these are counter-examples:

    S, MM, MSS

the first is invalid because it has no matches block. the second and
third are invalid because they each have contiguous blocks of the same
kind.



## what is a block formally?

any block may be seen as consisting of a series of one or more
contiguous lines (for our definition of line): every block starts cleanly
at the beginning of a line and every block ends cleanly at the end of a
line (either the same line or a subsequent one). we may think of a block
as an "autonomous unit" of one or more lines.

(to illustrate with an edge case, a zero-byte file could be modeled by one
block that has one line that is zero characters wide and terminated with
the zero-width LTS. by modeling the zero-byte file as having one such empty
line (and being able to model non-terminated lines more generally), this
gives the software the abililty (for example) to transform such features
programatically using the same infrastructure that we use to implement
any other kind of match replacement. this answers the question posed at
 #spot-3.)

static blocks are relatively straightforward: they are one or more
contiguous, complete lines each of which does *not* overlap with any
match. (to be clear this applies to each LTS of each line as well.)

matches blocks, then, are basically for everything else: every line of a
matches block will overlap with at least one match. somewhat conversely
(but axiomatically and with no proof), every match will be "covered" by
one (and only one) matches block.





## :#discussion-B: trying to make it a clean hierarchy is actually not pretty

TL;DR: we could make a tree that holds LTS's and matches together
(grouping LTS under matches), but it's more trouble than it's worth.

remember that per #axiom-A in the reference, LTS's and matches occur without
regard for each other. however, as for the LTS's and matches in a matches
block, we are conjecturing the following (i.e much of this is unproven here):

  • every such LTS exists (axiomatically) on a line that overlaps with
    at least one match. (a line that does not overlap with a match
    axiomatically belongs in a static block.)

  • for every such LTS that is *covered* by one match, we know that it
    overlaps with only that match an no other match (because matches
    cannot overlap), so we can safely imagine this match as "owning"
    this LTS.

  • for every such LTS that is "clear" of *any* match (that is, it does
    not overlap with a match at all):

    • axiomatically the LTS ends (effectively brings to bear) one line.

    • (again) every such line must overlap with a match.

    • since the LTS does not overlap with a match, there must be a match
      that ends on this line but *before* the LTS.

    if we needed to assign "stewardship" over this LTS to some match, we
    could chose whichever (necessarily existent) last match ended on this
    line (just because of its proximity).

  • the LTS could be the 2-character LTS whose first character
    (but not second) overlaps with a match.

  • the LTS could be the 2-character LTS whose second character
    (but not first) overlaps with a match.

  • the LTS could be the 2-character LTS whose first character is
    covered by one match and whose second character is covered by
    *another*!

we think the above covers all the spatial relationships any such LTS can
have with regards to the relevant matches in its block. fortunately we
aren't going to have to prove this because:

although our urge is to try and associate each LTS with one match (and
to store it there, even); the edge cases in the above bullets make for
logic that is uglier than is justified by the structural "simplicity"
that would be gained by trying to make a tree, in our current opinion.
as such we opt *not* to associate LTS's with matches directly..




## more about matches blocks - why "endcaps"? (:#decision-B)

remember that an LTS is mutable IFF it overlaps with a match. we should
assume (whether or not it's always true) that any mutable LTS can become
not-an-LTS, in effect joining its line to the next line (if any).

because of the aforementioned axiom of streamability, we need that every
matches block is guaranteed to begin and end "cleanly" on the boundaries
between lines (or the boundaries of the document itself).

to illustrate this, imagine a matches block with one line that has
some "ordinary" characters and then a UNIX-style newline:

    "AABB\n"

then imagine our (contrived) match expression is `/AA|B\n/`.
this gives us two (two to keep things interesting) matches in our one
line. (luckly for this example, these matches lie cleanly within this
one line, otherwise our matches block would have to be bigger to
accomodate all contiguous lines that overlap matches.)

then imagine that our replacement expression is "C".
this mutates our line to become:

    "CBC"

note that our LTS disappeared. now our block is no longer an autonomous
unit of complete lines. now, in order to make our line-stream-consuming
clients happy we would have to peek ahead to our any next static stream
and steal the first line off of it and so on. it's a mess we must avoid
which brings us to this decision:

    every matches block must end with an LTS that is immutable.





### synthesizing the above: the breaking algorithm :#the-conjecture

all relevant notes are under this tag in comments inline.




## next:

[#031] tagged throughput is the narrative successor to this.
