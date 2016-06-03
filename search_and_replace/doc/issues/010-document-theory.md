# document theory :[#010]

## objective & scope of this document

we develop an algorithm to produce and design a model for representing
the structures described in figure-1.

the overwrought approach here is arrived at practically: the theoretical
foundation that we build on achieves robustness through its simplicity.
in the algorithms that we then place over this foundation, whenever they
have holes these oversights invariably lead to bugs (manifest and dormant
both). as as such towards this end we offer our version of "proof" of
completeness.

"the reference" is [#005].





## how we represent and conceive of the document

  • for our purposes, our "document" and everything of interest within
    it exist in a "coordinate system" that we describe fully here: it
    is what we're calling a "1-dimensional" "discrete" "vector space".

  • we'll call each "unit" element of this vector space a "cel".
    we say "discrete" meaning that it is never useful for us to
    divide such a unit; that it is "atomic" like a pixel on a screen.

  • we *think* it's safe to say that in our conception, the "cel" of
    a document *is* each character of that document. (but in case it
    isn't, and because it often doesn't matter, as we develop our theory
    we use the more general "cel" instead of "character".)

  • "vector" is probably a misnomer (EDIT) (:A).

  • unlike with a screen that we commonly represent as 2-dimensional,
    for our document coordinate system we limit ourselves to only one
    dimension. in effect we are representing our document as a flat
    list of characters.

  • we'll say "formal cel" when we are referring to the position of
    the cel without regard to whether or not the cel is occupied by
    a character.

  • some formal cels are even "imaginary" meaning they cannot contain a
    character at all. e.g we might refer to the imaginary cel that occurs
    *before* the first cel of a string.




## significant spans inside our kinds of documents

(this section will rely heavily on terms introduced in the reference.)

  • "matches" and "line termination sequences" (LTS's) are both kinds of
    "significant spans" ("spans").

  • (although the document may contain characters that are outside of
    these classifications), our document "covers" 1-N "non-overlapping"
    LTS's and and 1-N non-overlapping matches.

  • that is, no LTS may overlap with any other LTS; and no match
    may overlap with any other match.

  • however matches occur without regard to where LTS's occur, and
    LTS's occur without regard to where matches occur (:#axiom-A).

  • by axiomatic definition, even the empty document will have at least one
    LTS because [#011] #decision-A we created a special LTS for this case.

  • the document with 0 matches is of no interest to us, and therefor
    outside of our scope; hence "all" documents have at least 1 match.




## defining and representing a boundary

when it is useful to speak not just in terms of cels but the "boundaries"
between them, we represent boundaries with an integer offset pointing
at the first formal cel *after* the boundary.

so for example the beginning boundary of any string (using the
coordinate system of that selfsame string) is the zero-width space
between the formal cel at offset 0 and the formal cel before it.
since the first cel after this boundary is at offset 0, that's what we
use to indicate this boundary.

for another example, the end boundary of the zero-width string is
also 0 by this strange justification: the "last cel" in the empty
string is the formal cel before formal cel at offset 0. so the
boundary that ends the string is the same boundary that begins it
(i.e the boundary discussed in the previous example).




## representing lines

we can represent a "line" as two boundaries, an end boundary and
a beginning boundary (the latter defined recursively):

  • the *end* boundary of the line the *end* boundary of the
    necessarily exactly one LTS that terminates it. (the LTS might
    be [#011] #decision-A zero width.)

  • the *beginning* boundary is the *end* boundary of the any
    adjacent previous line before it or (since none) charpos 0.




## next

the narrative successor of this is [#012] blocks.
