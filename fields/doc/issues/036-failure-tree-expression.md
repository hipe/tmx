# failure tree expression :[#036], or "understanding the structure of a failure"

## introduction

for most of its useful history until "recently", this event class was
quite simple: it was used to express lists of one or more missing
required fields. its expressive workload consisted mostly of allowing
for different noun lemmata to be specified for "attribute", and
effecting the "oxford-comma"-type expression on the list of missing
items, and this served us well for a "long time".

but then when [#ze-027]:#Crazytimes came along, this event class was
bent to serve it in what has become our most challenging natural
language production yet..




## explanation of the structure near `reasons` :[#here.A]

this member has been given the intentionally overly simple name `reasons`
with this comment added to help future-proof it from endless future
renames. its name suggests that it should be an array, with each item
perhaps being some sort of "reason" object. well it *is* an array, but
the structure of each item is a bit of a subjunctive:

at present each "reason" item is either a formal-attribute-like
(representing a missing required field, which is the classic use case)
*or* the item is a #[#ze-030.1] "reasoning" structure (see).

we want that this event structure is something like a simple recursive
tree with the following structure:

each branch node (certainly this root node, the event) can be said to
be composed of 1-N nodes, *each node* representing the "significant
unavailability reason" of the corresponding component of the correponding
interface node.

the most familiar kind of "significant unavailability reason" to us is that
of a "missing" required field. other kinds of significant unavailability
are the ultimate objective of this document, but we'll stick with this
example for now:

the members of information in this event that we care about for this
discussion are three: `reasons`, `selection_stack`, `lemma`.

unavailability,

    'have dinner' is missing the required parameter 'money' (a)
    also, 'have dinner' requires 'foo' and 'bar' which failed to load.  (b)

    (or better would be): can't 'have dinner' without 'money' (c)
    also, can't 'have dinner' because can't 'take subway' and can't ..  (d)

    can't 'take subway' because can't 'get ventra card'.
    can't 'get ventra card' without 'money'.




## this event expresses as a stream of statement-ishes :[#here.B]

a "statementish" is something like a sentence-phrase (e.g "it is
missing FOO") or a meaningful sentence fragment (e.g "missing FOO").

this event will express its constituency as a stream of such
statement-ishes, where in effect a one-to-one isomorphicism is formed
between a statement-ish and output "line": each item always has a
trailing newline; and before that there is a terminating period if
the statement-ish had a subject (i.e was sentence-phrase-ish).




## similar statement-ishes are aggregated into compound statement-ishes.. [#here.C]

if we are missing A and we are missing B, rather that express those
sentiments as separate statement-ishes ("missing A" "missing B"), we
can unawkwardly aggregate the expression of both ideas into one
statement-ish: "missing A and B".

'A' and 'B' in this example are "attributes". (we might also call them
"components" or "nodes".) it would be fair to say that we can aggregate
them into the same statement-ish because they have the same kind of
reason (or more precisely, a similarly shaped "attribute predicate").
(for the curious, the theory behind this "aggregation" is voluminous,
and is the focus of [#hu-002].)




## enter recursion

..but let's say also that we are (in effect) missing D and E, but that
D and E are not plain old attributes like A and B are: D and E are
themselves "compound components" (maybe like [#ac-022]):

D is missing F and G. E is missing G, H, and J. G, in turn, is another
compound component which is missing J.

so suddenly this crazy acyclic directed graph is composed of eight nodes
and six arcs (not counting the unnamed root node that holds the nodes
without a named parent..)

          A
          B
          D -> F
           \
            *---> G --
                  ^    \
          E -----/      |
           \            v
            \---------> J
             \
              ---> H

          fig. 1.

([#here]/figure-1.dot is a graph-viz diagram of this.)

here is a fuzzy sketch of several expression strategies for this craziness:

  the first time a branch node is traversed, descend.

  each (if any) subsequent time it is traversed, do not descend.



if we wanted to be really cool,

  summarize in the first statement (or depending on style, a final
  statement) by explicating only all the atoms:

    "cannot [root] without A, B, H and J:"

    "cannot [root]..

(we are not this cool yet.) but this is how cool we yet are:





## :"the story"

### :[#here.4]

somewhere, somehow a recursive-style [#ze-030.1] "reasoning" object is created.
(happens in [ze].)




### :[#here.5]

somewhere, somehow this recursive-style [#ze-030.1] "reasoning" object is added
to the array of mixed reasoning objects.
(happens in [ac].)



### :"storypoint-3": depth first vs. synopses first :[#here.F]

we express synopses first partially so that aggregation can work:
aggregation needs its input stream to be complete before it can flush.

as such, we cannot do a "depth first" form of expression for this tree
*and* have aggregation. aggregation precludes depth first
unless you wanted to add some sort of "sort by categorizing" pass which
we are not interested in doing at this stage.

in its stead we
  1) do the aggregation pass
  2) while gathering would-be recurses and then
  3) flush the recurses *after* the "synopses" have been expressed..
_
