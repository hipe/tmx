---
title: "a collection synchronization algorithm"
date: "2018-04-24T05:27:25-04:00"
---
# a collection synchronization algorithm

## objective & scope

"synchronize" "collections".




## status of this document

- at #history-A.1:
introduce the "interleaving" algorithm.




## history

- before #history-A.1:
this is used successfully at the collection level and within items
(the "recursion" discussed below).
- at birth:
we are eager to explore this in some tests to see how painful the
recursive approach is.




## brief definition of "collection"

  - an *ordered* list of *items* (for meanings of "item" discussed here
    and "ordered" throughout this document).
  - for each item it must be possible to derive from it a key that
    identifies the item uniquely in the collection. (:"provision 1")
  - not a requirement, but note that the item will typically have a
    "surface representation" (e.g how the item would appear in a file).
  - in our inspiration-case application of this algorithm, it has in fact
    proven useful to allow this algorithm to recurse into itself once.
    (this is the subject of a section below.)




## "near" vs. "far"

we used to say "local" vs. "remote", "original" vs. "new".




## define "synchronize"

for our intended application, to "synchronize" means to "import" (or maybe
we will prefer "merge") data from a "far" "collection" "into" our "near"
one. we require that each item have a "natural key". places this gets
interesting is where it bumps into issues of

  - collision: what do we do when a far item has the same natural key as a
    near one?
  - possible pruning: if an item exists in the near collection but not
    far collection (in terms of natural key), do we omit that item from
    the result collection?
  - sorting/order: ...




## how these algorithms can recurse on themselves, definitionally

in our inspiration-case application of this algorithm, it has proven useful
to allow this algorithm to recurse into itself once. (this was applied
usefully before #history-A.1).

in more detail, this algorithm has been used at the collection-level merge
and also at item-level merges (a.k.a a "sub-item-level" merge). in so doing,
our formal definition for "collection" is applied to our practical
collections but also to the individual item as well, which we can model as
nothing more than a collection of name-value pairs:

| application of this algorithm | what acts as the collection? | what acts as the item? | the natural key? |
|---|---|---|---|
| at the collection level | the collection | each item            | user-defined function against item |
| at the sub-item level   | the item       | each name-value pair | each name of same |

this won't really make sense at this early stage; but just know that we
use this algorithm to merge one collection into another and also this same
algorithm to merge one item into another.




## behavioral facet (option): original- vs. new-order

the order of the output sequence can be centric to either local (original)
or remote (new) order.

(we also have an "insertion" "algorithm" that's lexical based but respects
the weird ordering of the original document. that's straightforward, has
been implemented by us elsewhere, and is of no interest to us here.)

from a practical standpoint, we can think of advantages to both.

advantages to new-order-centric might be if you think of the remote
datasource as authoritative in regards to the order. in such cases you
might want the synchronization to "correct" your order (so your (for
example) document "looks more right" in this regard).

on the other hand, an original-order-centric synchronization could have
advantages like so: imagine that you make discretionary decisions about
the ordering of the items in your local datastore; for example, it's a
document and you place the most significant (or most recent) items near
the top of the list. in such a system you would want synchronization to
try to preserve this meaningful ordering that you already have to whatever
extent is possible appropriate to the other parameters of the synchorniation.

or perhaps the remote data source does not express any significant
meaningingful order in the first place, and so you simply want to minimize
the impact of meaningless change to your (for example) document.

we were at first going to make it new-order-centric by default, but now
we are going to make it original-order-centric by default (specifically
because the example reasons we just cited are in fact based on real-world
use cases are are compelling to us).

(#edit [#447.B] at writing we have not yet exposed an option for "order centricity"
(i.e near-centric vs. far-centric, introduced next), but we state
this all here now so we can give thought to it as we write the algorithm.)




## behavioral facet (option): ordering (theory)

we can imagine an uninteresting number of permutations of different ordering
policies to be exhibited by the output sequence, contingent on ther requisite
options being implemented.

(although the below list makes no effort to communicate this, it should be
inferable that some choices are mutually exclusive with others, whereas
others can combine.)

for example:

  - hew to the found sequence of the far collection (inserts at end)
  - hew to the found sequence of the near collection (inserts at end)
  - insert at beginning instead of end
  - apply some sort of sort to the far collection first
  - apply some sort of sort to the near collection first
  - insert e.g lexically, but retain found ordering of near

the first two alternatives suggest one interesting axis: the ordering can
be near-centric or far-centric. from a practical design standpoint each
may have its own strengths based on the use case:

advantages to far-order-centric might be if you think of the remote
datasource as authoritative in regards to the order. in such cases you
might want the synchronization to "correct" your order (so your (for
example) document "looks more right" in this regard).

on the other hand, a near-order-centric synchronization might have these
advantages: imagine that you make discretionary decisions about
the ordering of the items in your local datastore; for example, it's a
document and you place the most significant (or most recent) items near
the top of the list. in such a system you would want synchronization to
try to preserve this meaningful ordering that you already have to whatever
extent is possible appropriate to the other parameters of the synchorniation.

or perhaps the remote data source does not express any significant
meaningingful order in the first place, and so you simply want to minimize
the impact of meaningless change to your (for example) document.




## behavioral facet (option): pruning

this imagined option would be for whether or not you would want the
synchronization to remove from your near collection those items that
are not also in the far collection (in terms of their natural key).

.#edit [#447.B] at present we are not going to implement this, but we should
consider how such a requirement would manifest in our algorithm nonetheless.

probably what we will do as the default (and at first only) behavior is
to emit a notice for those items that (by name) are in the original
collection but not in the new collection. this would leave the onus on the
person to delete such items manually as necessary and if desired. for our
imagined real-world use case this will probbaly suffice for the near term.




## <a name=7></a>the outer (document-centric) algorithm (overview)

in its purest terms, synchronization must not be thought of as always
having a "document" as the substrate. but in practical terms it may very
well be so we'll approach our algoirthm from the outside-in assuming the
synchronization target is a document (but knowing that a document-centric
approach will down-grade well enough to formats that are not
document-centric (like if you're just manipulating rows in a database
that have an `order` integer column)).

anyway, in approaching this from the standpoint of practical considerations
for documents, this lays down a higher-level algorithmic framing into which
our subsequent lower-level work will fit.

basically, it's
  - output the static first part of the document (N lines).
  - output the partially changed middle part of the document (N lines).
  - output the static last part of the document (N lines).

(where each "N" is zero or more).

what we mean by "output" is important:

  - don't assume you are necessarily writing to a file on the filesystem
    (unless you really have to assume this). there are some coarse
    advantages to thinking of file IO as line-based instead of byte-based #edit [#447.B]

  - there CAN be advantages to modeling your document production as
    stream-like instead of iterative; but MAYBE some implementation
    platforms (python) mitigate the significance of this more than
    others (ruby).

in the old days we used to think of a synchronization in terms of *three*
endpoints: an _upstream_, a _downstream_ and a _herestream_. basically
the idea was: pull in new data from the upstream, merge it in with existing
data in the herestream, and write the new collection (document, e.g) to the
downstream. an edit-in-place behavior (like the `-i` option for `sed`)
could be achieved by getting the output of the downstream ultimately into
the the storage resource (e.g file on the filesystem) whence came the
herestream. (this can take some work - just like how on the shell you can't
redirect the output of a thing into a file that you use for input.)

but now (and to get _very_ practical for a moment), we have simplified this
distinction away. now we _always_ write output to a temporary file (called
"downstream" above), and then run `diff` between the "herestream" file and
the temporary file. we always and only ever output the diff (a "patch") as
the final output of our program.

having your output be a patch rather then (either) edit-in-place or
ouputting a full, new document; it gives you this triad (plus) of benefits:

  - _useful:_ the output is always useful (and complete), while being
    visually minimal for typical cases (concise). it highlights only
    those parts that have changed while still being losslessly isomorphic
    with a full "after" document.

  - _safe:_ we don't have to worry about accidentally fudging a
    `--dry-run` or `--force` parameter and clobbering the user's data.
    (the user has to worry about it! but if she knows how to apply a patch
    we can safely assume etc.)

  - _simple:_ this simplifies the interface without sacraficing power,
    and comes at a cost in convenience that we see as negligible.
    accomplishing this is probably some kind of design principle somewhere #edit [#447.B]

  - _upgrade path:_ by targeting this behavior we are not trapped in it.
    accomplishing a `-i`-like option could be possible through etc.
    adding such a feature could exist as a layer that sits on _top_ of
    of our work, instead of it needing to be injected _in_ to it.

anyway, now that we have outlined the practical considerations for
real-world use of this:




## the diminishing pool algorithm

in overview,

  - gather up a "diminishing pool" by traversing the far collection to index it
  - traverse the near collection while consuming matches from the diminshing pool
  - flush any left over in the diminishing pool.
also:
  - if you swap "near" and "far" above, you get ordering that is
    far-centric rather than near.

we are going to start with targeting a original-centric-ordering.

you can implement an original-centric-ordering by iterating (or streaming)
over the components your _existing_ collection, at each step using an index
of the _new_ collection to effect the synchronization.

(if you were instead to implement a new-centric ordering; you would first
index the existing collection, then use a traversal of the _new_ items to
guide your output.)

note that the essential difference between these two "centricisms" of
ordering is in what you index, and whose traversal you let drive the
outputing of the new collection; but they are essentially the same:

  - original-centric: (traverse and) index the new, then traverse the original.
  - new-centric: (traverse and) index the original, then traverse the new.

(before going any further, note that no matter what you will be traversing
the entirety of each collection either way.)

also there is the essential matter of what to do when you've reached the
end of your "driving traversal". what we do here is something we call
"flushing the diminishing pool".

so, the pieces in more detail:



### index the new collection (which traverses it)

you will turn the collection (a stream) into a "diminshing pool".
(NOTE in-memory vs e.g redis vs e.g a database vs ?? #edit [#447.B]).

the "diminishing pool" won't be diminishing yet at this phase, so
in fact we can think of it as a mutable ordered dictionary. (in our
current implementation platform, dictionaries are insertion ordered
which is great. this is way out of scope for pseudocode 😁)

    start a new, empty, mutable dictionary ("the index").

    for each item from the collection stream,

      get its natural key ("name").

      if this item already exists by name in the index,
        this is a synchronization failure. stop everything [:e1].

      since this item does not yet exist in the index, we procede.

      add this item to the index by name.

    when all is finished:
      - you have an empty (exhaused) collection stream,
      - and ALL N items stored in your dictionary ("index"),
        indexed by natural key ("name").

actually, that's it! the body of this would take perhaps 3 or 4 lines
of code. neat.



### traverse the original collection, while doing a thing

    we will be using "the index" from the previous section.
    but acutally, make "the index" into a "diminishing pool".

    for each item from the original collection stream,

      get its natural key ("name").

      does this item exist (by name) in the index?

      if yes,
        this is called an "item synchronization". see the next section.

      otherwise (and the item does not exist (by name) in the index),
        output the "surface representation" of the item as-is now. [:ar1]

    at the end of this:
      - the original collection stream is exhausted.
      - zero to N items have been outputted (as surface representation)
      - the diminishing pool has zero to M remaining items.



### item synchronization

this is what happens when there's a sort-of "collision" during sychronizing.
this is (if it's not obvious) the interesting part.

    for this would-be function, you have:
      - a "new item" (from your diminishing pool/index)
      - an "original item" (that is part of the stream you are traversing)
    these both have the same natural key ("name").

    to determine what to do, we first "compare" these items by making a
    "structural diff" of them.

    no, wait. actually what we *can* do is this: our similar algorithm
    again, recursed once.

    but the difference is: when we come back to here, we have two values.

    if one or more of the values is not atomic (if it is compound),
    this is a synchronization failure. explain it and stop everything. [:e2]

    now, a comparison of the two values will (for the type of comparison
    we require) result in one of two cases:

      - the two values *are* equal.
      - the two values are *not* equal.

    when the values are equal, you "pass-thru rewrite" the original
    visual element. [:ar2]

    when the values are not equal, what to do in this case is a matter
    of policy (i.e not very interesting):

      - you could prefer the new value to the original value.
      - you could prefer the original value to the new value.
        (you should probably emit a notice or similar here.)
      - you could say this is an unrecoverable ambiguity, and error out [:e3]

    if your policy calls for the first of the three options, then how to
    write the new value (as a visual element) is a matter for the format
    adapter to know. [:ar3]



### flush the diminishing pool

(remember we are framing this under original-centric ordering). having
traversed stream of items in the original collection, we have processed
(and removed) from the "diminishing pool" those items that were a collision
by name with exisitng items.

so at this point we are left with a diminishing pool with zero or more
items, a collection that represents those items whose names were present
in the new collection but did not exist (by name) in the original collection.

    for each item that remains in the diminishing pool,

      write the new item [:ar4]

that's it! note that this will have the effect of having new items always
appended (not prepended) to the list of existing items. (it would require
more storage but we could take steps to make this a configurable option
so that for example these new items are inserted (in the same order with
respect to each other) at the head of the collection of items.)

however, given what we said above (near "discretionary"), along with the
probablistic characteristics of our target use-cases, we expect that this
behavioral provision will be fine.




## algorithm: interleaving

this algorithm was introduced as a counterpoint to the "diminishing pool"
algorithm above because the above presented a few issues when we were using
it for our at the (#history-A.1) time current inspiration use case:

when doing a true data merge with multiple sources, the diminishing pool
algorithm has drawbacks: the output order can feel happenstance, and so it
it doesn't help us detect near-misses for desired collisions (item-level
merges) because it doesn't put like-keys near each other. the pattern became
us editing the outputted table by hand to have the rows be in alphabetical
order by key, something we anticipated being no big deal but in fact grew
untenably cumbersome-feeling after about two iterations.

in effect, what we wanted was a synchronization that alphabetized the result.
it felt cludgy not to have the synchronization be stream-y as well. the
buy-in to accomplish this is that the input traversals themselves already be
ordered.

so, quick pro's and con's. pro's:

  - items with like-names (for definitions of) are near each other.

  - the outputted markdown table has a deterministic ordering, regardless
    of the order that the sources are input.

con's

  - you will lose any meaningful ordering that the source collection exhibits,
    something that hurts us for more typical cases of using a web page as a
    datasource, where the order of items is often somehow significant
    (narratively or otherwise).

here's how it works in a normal case, coarsely:

    far_item, far_key = next_far_item()
    near_item, near_key = next_near_item()

    while far_item is not None and near_item is not None:

        if near_key < far_key
            yield near_item
            near_item, near_key = next_near_item()
        elif near_key == far_key
            yield merge_the_two_items(far_key, near_key)
        else
            yield far_item
            far_item, far_key = next_far_item()

the idea is that you pop off the head of each stream and whichever one should
go out first goes out first and then is replaced with the next head of that
stream, all the while checking if each new pairing is a match. as this repeats,
whichever stream should be drawn from is drawn from until one or both of them
finds its end.

note that:

  - we are using the "lexical" values of the (string) keys *as* the sorting
    criteria. this is crude, but it's a move to keep the number of moving
    parts low until there's good reason not to. :"provision 2"

  - unlike the previous algorithm, we are not looking up keys against
    a hash of other keys. we rely on the matching keys "just ending up"
    beside each other, something that requires that the source streams be
    already ordered.

  - one part that we don't illustrate above is the "run down" leg of the
    algorithm. this part is more straighforward, documented in the code.



## internal API requirements for format adapters

  - re-output the surface representation of an original item.
    (i.e "pass-thru rewrite"). (ar1)

  - "pass-thru rewrite" of an original name-value pair. (ar2)

  - be able to write a name-value pair for a _new_ value
    (possibly a new name-value). this may require templating
    and/or heuristic re-use of separators, etc. (ar3)

  - be able to write an entirely new item. (so the above plus
    possibly more.) again, may reqiure templating. (ar4)




## appendix: synopsis of options we might have one day but won't do now:

  - change order-centricism from original-centric to new-centric
  - prune instead of notice
  - other insertion algorithms, like at-head or lexical-esque.




## (document-meta)

  - #history-A.1: spike the new interleaving algorithm
  - #born.
