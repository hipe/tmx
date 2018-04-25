# a collection synchronization algorithm

## status of this document

we are eager to explore this in some tests to see how painful the
recursive approach is.




## objective & scope

"synchronize" "collections".




## brief definition of "collection"

  - consists of nothing more than 'items'.
  - ordered.
  - for now, item must have a "natural key" that identifies it uniquely
    in the collection. (<a name='provision-3'>:provision 3</a>)
  - items can be seen as a flat, ordered list of name-value pairs.
  - the item can (but not must) have a "surface representation"
  - an item, in turn, is defined somewhat recursively using more or less
    this same definition for "collection". (however: currently we do not
    want these formal structures to recurse more than one level deep.
    rather than using the same terminology, we say that items consist of
    name-value pairs.)





## define "synchronize"

it can mean a variety of things. EDIT






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

(EDIT order centricity is probably not an option at this point, but we state
this all here now so we can give thought to it as we write the algorithm.)




## behavioral facet (option): pruning

this imagined option would be for whether or not you would want the
synchronization to remove from your local collection those items that
were not also in the remote collection (in terms of their natural key).

EDIT at present we are not going to implement this, but we should
consider how such a requirement would manifest in our algorithm nonetheless.

probably what we will do as the default (and at first only) behavior is
to emit a notice for those items that (by name) are in the original
collection but not in the new collection. this would leave the onus on the
person to delete such items manually as necessary and if desired. for our
imagined real-world use case this will probbaly suffice for the near term.




## the outer (document-centric) algorithm (overview)

in its purest terms, synchronization must not be thought of as always
having a "document" as the substrate. but in practical terms it may very
well be so we'll approach our algoirthm from the outside-in assuming the
synchronization target is a document (but knowing that a document-centric
approach will down-grade well enough to formats that are not
document-centric (like if you're just manipulating rows in a database
that have an `order` integer column).

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
    advantages to thinking of file IO as line-based instead of byte-based EDIT.

  - there CAN be advantages to modeling your document production as
    stream-like instead of iterative; but MAYBE some implementation
    platforms (python) mitigate the significance of this more than
    others (ruby).

in the old days we used to think of a synchronization in terms of *three*
endpoints: an _upstream_, a _downstream_ and a _herestream_. basically
the idea was: pull in new data from the upstream, merge it in with existing
data in the herestream, and write the new collection (document, e.g) to the
downstream. an edit-in-place behavior (like the `-i` option for `sed`)
could be achieved by having the herestream and the downstream point to the
same resource (e.g file on the filesystem).

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
    accomplishing this is probably some kind of design principle somewhere EDIT

  - _upgrade path:_ by targeting this behavior we are not trapped in it.
    accomplishing a `-i`-like option could be possible through etc.
    adding such a feature could exist as a layer that sits on _top_ of
    of our work, instead of it needing to be injected _in_ to it.

anyway, now that we have outlined the practical considerations for
real-world use of this:




## the inner (main) algorithm (an overview)

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




## the inner (main) algorithm (in more detail)

again we are targeting a original-centric-ordering, but keep in mind that
hopeufully the parts of this will be interchangeble in a modular way if you
were to target the other order-centricism. (but for the purposes of
visualizing and understanding the algorithm, it may help to convey it
in these more concrete terms at first.)

so, at a high level:
  - index the new collection (which traverses it)
  - traverse the original collection, while doing a thing
  - flush the diminishing pool

so, the pieces:



### index the new collection (which traverses it)

you will turn the collection (a stream) into a "diminshing pool".
(NOTE in-memory vs e.g redis vs e.g a database vs ?? EDIT).

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

  - #born.
