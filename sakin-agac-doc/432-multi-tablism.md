---
title: muli-tablism hello
date: 2018-12-23T21:29:00-05:00
---

there comes times where it's convenient to have multiple tables in one
document, all of which are part of the same broad collection of data.

(a contrived example is an actor's wikipedia page: there might be one
table for "filmography" and one for "television". although the data may be
structured similarly in the two tables, it "makes sense" to have them
separate, because of their semantic (and possibly structural) distinctiveness.)

although at first it may seems to be only a superficial concern (that is,
one having only to do with some "view layer" (imagined or actual)), in fact
such a superficial concerns are of interest to us here because of the
isomophicisms we leverage between document structure and data storage.

we refer to this phenomenon as "multi-tablism"
in the context of this sub-project and clients that use it.

now, separately we've proven to ourselves that "syncing" is a useful way
to .. ingest changes in our data from various external sources. (indeed
syncing could be seen as some kind of fundamental theoretical pillar of the
whole sub-project.)

so to the point: to get syncing to work with multi-tablism,
entity identfiers will go from being plain old "values" (strings) in a shared
namespace to being tuples that have to be aware of a stack (later for this).

this will be a non-trivial amount of work to inject this change into the
sync function and still maintain compatibility with the majority of data
providers which are not multi-table.

the path forward to this may be somewhat simple. conversely, it maybe be
a crazy paradigm alerting thing where we recurse the algorithm, folding it
into itself. but nonetheless, this is all out of scope at this writing.




## (document-meta)

  - #born.
