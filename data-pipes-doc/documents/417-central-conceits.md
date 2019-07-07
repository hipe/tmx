---
title: "central conceits"
date: "2018-09-02T19:10:48-04:00"
---
# central conceits

## <a name=A></a> central conceit: the JSON wall (lingua franca)

  - be sure to see the excellent ASCII diagram and description at `:[#417.A]`
  - in summary, one pipey interface to rule them all (sort of)




## <a name=B></a> central conceit: markdown table as datastore

  - this central underpinning of a lot of this is explained nowhere..




## <a name=C></a> central conceit: syncing and nativization

conveniently, this item combines the two before it.

the "central conceit" of the sync script (in its adaptation provided by
the markdown tables format adapter) is that it takes a stream of [#417.A]
normal records (dictionaries) and in effect turns them into markdown table
rows, sort of.

as something of a [#415.S] contentious design decision, we conceive of
markdown tables as being justified columns of data (so, fixed-with ASCII
lines of text that line up with each other vertically in some way).

you can then conceive of a full markdown table "cel" as containing not
only a surface string representation of the value, but also the 'margin' of
zero or more spaces to the left and again to the right of the surface string.

then consider that a normal record (dictionary) does not itself have this
extra "information" in it of these margins (and nor should it, being as it
is a surface concern specific to this particular surface phenomenon of the
particular format).

so what it amounts to is that we need to get this information from somewhere.
towards this, generally our design guidelines are:

  - it's better to try to infer this kind of thing from the peculiarities
    of the existing document rather than making heuristic decisions on
    our own in a vacuum

  - it's better to [same] rather than adding configuration options for it.

we now call this idea :[#418.3] heuristic templating.

in order to meet the above design guidelines we pull of a dastardly bit of
hackery that we call the :[#481.D] the "prototype row" and it works like so:

our nascent, experimental convention is that the first row of the markdown
table is used *only* as an example, to show how to format other rows.

this "prototype row" can then take the knowledge it has about target widths
for each field (while this misfeature persists) and with that, produce new
rows for the markdown table. we have now generalized this into the idea of
a "nativizer" because it takes the pure, [#417.A] normal records from the
far collection and turns them into crunchy, surface-tailored native records.

(so when we say that a record is "nativized", we mean that it appears as a
markdown row and takes on the formatting of the particular document (per
the above introduced ideas of heuristic templating and example row).)




## <a name="C.2"></a>(specific challenges with nativization here)

what makes this tricky is the stream-centric nature of the synchronization:
in ideal cases our synchronization algorithms work by processing both streams
item by item in their order with no large-scale caching, so that
synchronization can scale linearly to very large datasets (both near and far).

but note you can't output a "nativized" far item until you've seen the
[#418.D] example row, which is why the example row must be a non-
participating row that always appears first.

so this magnetic tries to thread the needle: it uses a "random access"
paradigm for the first record, then expects the rest is used streamily.




## (document-meta)

  - #abstracted.
