# the aggregating articulator :[#055]

## introduction

the aggregating articulator is a reducing/expanding scanner meant to be
attached to another scanner that will act as produer. the aggregator's
particular forte centers around detecting and transforming repetition
that comes in from the upstream in some way that typically makes the
outstream variously more condensed, more explicit, more natural sounding,
or just more fun; based on the transformation functions the user provides.



## theory

communication to the human seems to be optimal when we strike the right
balance between the two poles of redundancy and ambiguity. too much
redundancy (that is, a relatively low amount of new information) is
boring, or at worst can interfere with one's ability to find any
relevance in the message stream.

in the other direction, when too little context is provided, or the
information is too dense or otherwise not decipherable, communication
falters just as well.




## specific theory

at this time there are at least three kinds of repetition that are
detected and more than three ways to deal with them:

  1) frame-level repetition. this means that the whole frame (sentence)
     is repeated, that is, it is identical to a frame that has gone
     before it.

  2) field-level repeption (long-running). we can keep a count on how
     many times each value occurs for each field. when a same value
     comes out a subsequent time for a field, we can associate behavior
     with this state.

  3) field-level repetition (contiguous). when some but not all field
     values comes out with the same values that were in those fields
     on the frame(s) immediately before this one, we can start to do
     some really novel hacks.

the behavior we like to employ for expressing these phenomena generally
falls into two families: 1) "acknowledged redundancy" and 2)
"aggregation".

"acknowledging redunancy" is something like saying "yes, this
information isn't new and I know it isn't new, and in case you suspected
it isn't new, this is me telling you you are right." it's not just
decoration: it can also serve as a marker to aid the interlocutor in
seeing patterns she might otherwise have paid less attention to. it's
about connecting ideas.

we do this hundreds of times a day without noticing it: whenever we
communicate frames of ideas nearby each other that have something
similar about them, we are expected to insert words that cradle these
similarities.

the other strategy (that is perhaps in opposition to the first) is
"aggregation". aggregation re-bundles in the information in a new way to
reduce the redundacy. we think of it as lossless information compression.

the relative benefits and disadvantages to these two strategies has yet
to be formalized here, but one thing is certain: aggregation is
definitely the more difficult of the two to implement.




## :#note-310

in any given repetition among some particular subset of the fields,
aggregators are not used on the repeating fields. they are used
as a strategy to compress the other values that are not repeating.
so we need to be sure we have aggregators for those fields or we
cannot perform the aggregation. also, in those cases where we have
more than one non-repeating field, will will lose information by
creating ambiguity if we try to aggregate these multiple frames.
consider:

  "jack and jill went to france and spain [respectively]"


without the "respectively" (we we certainly are not going to
generate today) the two-field aggregation is ambiguous.
so for now the rule is, only 1 non-repeating field.
