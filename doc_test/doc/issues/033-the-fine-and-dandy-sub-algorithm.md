# refinement one: the "fine and dandy" synchronization sub-algorithm

this will somehow work into our grand #forwards-synchronization-algorithm,
whose overview is [#017].

we will explain this goofy name at the end of this section.

for the purpose of explaining this facet of the algorithm, let's imagine
that both "asset file" and "test file" are a list of one or more *tests*,
and while a test will normally be identified by its description string,
(and normally these files may have more structure to them), for our goal
now we will represent these files as a flat *list* of items, each item
being represented by a letter of the alphabet. so A, B, C, D and E are
tests, and each test exists (by name) in either one or both sides when
we start.

"syncing" (here) means simply *writing* content from the source document
(the asset file) to the destination document somehow (the test file).

this example will illustrate most of what we are trying to demonstrate:

    asset file              test file before

          A                      D
          B                      B
          C                      E

                             test file after

                                 A (added)
                                 D (uninvolved)
                                 B (modified)
                                 C (added)
                                 E (uninvolved)

just by scrutinizing the above you *may* be able to postulate what our
algorithm is. your answer should include a rationale for why we put "A"
and "C" where we did.

we can arrive at the above by these rules:

 1. every single item from the source will be written to the destination.
    when we say "sync", we simply mean "write content from the source to
    the destination".

 2. we "sync" each item from source to destination one-by-one in the
    order in which they exist in the source document. so, for each item:

 3. if the item exists in the destination document (by name), overwrite the
    content of that node what that of the source item. (we won't bother
    checking if the content is byte-for-byte the same, probably.)
    (in the example, item (B) exercises this rule.)
    (#coverpoint3-2)

 4. if the item does *not* exist in the destination document (by name) and it
    *is* the first item in the source, *prepend* the item to the destination
    document. (that is, place it before any/all other items in the destination
    document.) (in the example, item (A) exercises this rule.)
    (#coverpoint3-1)

 5. otherwise (and neither rule (3) nor rule (4) applies), this case applies.
    the following sentence is a mouthful to parse, but we dissect it
    immediately following:

    if the subject item does *not* exist in the destination document
    (by name) and it is *not* the first item in the source document, then
    insert the item in the destination document immediately after the item
    that exists immediatly above the subject item in the source document.

    so first off, how did we get here? since we did not match rule (3)
    (which covers those items that already exist in the destination
    document), we know that this item does not yet exist in the destination
    document. following rule (1) we must put this new item somewhere in
    the desination document.

    at this point we could just append the item to the destination "list",
    but that's too simple. that is, such a solution falls short of one or
    more of our design factors (to be discussed below).

    so recall too that we fell past rule (4) which applies to items that
    are first in the source and not in the destination. since we are not
    in the destination and rule (4) did not apply to us, we know that we
    are not first in the list of items in the source document (because if
    we had been, that rule would have applied to us and not this default
    case).

    this is to say there is definitely at least one item above us in the
    source document. finally, recall rule (2): we sync each item one-by-one
    in the order in which they appear in the source document. this means that
    those one or more items that are definitely above us in the source
    document have definitely been synced already.

    all together this means that whatever item exists above us in the source
    document, that item is guaranteed to exist now in the destination
    document. it is this item that we insert ourselves immediately after in
    the destination document. whew!

    *why* we do it this way is the subject of its own section below.

    (in the example, item (C) exercises this rule.)
    (#coverpoint3-3)

 6. perhaps as a corollary of the all of the above rules but stated here
    explicitly, those items that exist (by name) in the destination but not
    in the source will remain in the destination after synchronization.

    these items will remain more or less "where they are", a sentiment we
    don't define rigorously except to say that for each such item, those
    items that (by name) existed "above" it (in terms of line number) and
    those items that existed "below" it (same) will, after synchronization,
    still exist (perhaps on different line numbers but) with this same
    spatial relationship to the item, and to each other - that is, items are
    only ever added or modified, and the initial order of the original items
    is preserved. (just note that new items may be inserted at arbitrary
    locations.)

    ((D) and (E) demonstrate this.)
    (#coverpoint3-4)




## consequences of the "fine and dandy" sub-algorithm

these rules has several consequences that satisfy some design factors
over a simpler algorithm, like one that simply appends new items to
the destination "list"; or our older "generation" pattern (that this
newer "synchronization" is a replacement for) where the process of producing
the test file did not take into account the data that was already there,
but rather clobbered everything at each generation.

aspect by aspect we'll go over the behavior characteristics of this new
sub-algorithm in more detail and then explain the value and cost of each.



### synchronization is (sort of) lossless

with the concert of rule (1) and rule (6), at the item level the only
way forwards synchronization takes away information is when a rule (3)
case overwrites what is in the destination. otherwise information is only
ever added to the destination (with regard to the payloads of items).

to be more precise, information that we *might* lose is in the form of
(A) whatever content data used to exist in items that are being overwritten,
and (B) the exact structural state that existed in the destination document
before the sync happened - that is to say, the spatial relationships of
which items are higher or lower than which other items, this is preserved;
but who an item's immediate neighbors are is not guaranteed to remain the
same, pursuant to the fact that new items may be inserted at any arbitrary
locations.



### the narrative gets more weight than the text document when inserting

for those cases when we're adding new items, this algorithm gives
more weight to the spatial relationships that are on the source document
(the assset document) side over those in the destination document (test
document) side: whatever "feature of interest" is above the item on the
source side (where "feature of interest" is "other item" or "beginning
of the list"), that item is guaranteed to persist as the previous item
on the destination side.

however, for items that already exist in the destination document, this
algorithm will not "move them around" (for definitions of moving).

the rationale here is that typically, a use case that is being illustrated
in a "participating" doc-test compatible comment is usually a more essential
(and perhaps simple) case, so from a regressibility standpoint it makes sense
to have it appear earlier in the actual test document. however because the
test document gets final say in the positioning of the item, the user is not
restricted by this; i.e it's a default behavior, not a constraint.



### caveat: how to screw things up

whenever you change the "name" (actually description) in either the
source or destination, the connection between these two nodes is broken
and when you sync you will end up with probably unintended near-duplication
of content (test logic) under different names.

although we heartily recommend that you modify your test names as you
refine what the test is doing, the cost of doing this while using the
subject system is that you must distribute such name changes "manually"
to both places (asset file and test file) and be sure that the new name is
byte-for-byte the same after encoding (e.g backslashes on double quotes on
the test side).




## summary

this algorithm is "seamless" and "cannot fail" which is all "fine and dandy"
but here's the rub: it doesn't fully isomorph to the complexity of our model.

this algorithm defines (in effect) a way to merge a new ordered hash into an
existing ordered hash (or just say "list" (of unique items) if you prefer).
but our asset documents and test documents are not merely flat lists
of (test) items: they can have another dimension of structure to them:
contexts.

but this does not mean we have to throw all this work away. on the contrary
each of our six rules above will be carried (somehow) into this new
dimension of depth, a depth that we dive into in [#034]..
