---
title: filetree schemas
date: 2018-12-19T04:47:00-05:00
---

## why constrain ourselves?

recall from our README that a central design tenet is to be human-readable
and easy to work with and easy to understand.
with these principles in mind
(and without knowing yet what we mean by "entity"),
here we imagine ways we can
model mappings between entities and filesystem files.

a quick proviso
(and without knowing yet what we mean by "collection"):
if your collection involves hundreds of thousands of entities or more,
it's almost certainly against god and reason
to continue using this datastore.

(there's the tiniest chance that some of our imagined features will remain
useful at scale, but it's going to be a while before we're in a
position to know that.)




## finding our first constraint

accept as axiomatic that entities live in files.
as the number of entities increases,
it is not the case that we want the file to grow infinitely large.

recall from our README that human readability is a primary design tenet.
even if the underlying filesystem can accomodate very large files;
if the human has to scroll over "many" lines to get to a particular item,
we consider that to be in conflict with principle.

this can also be a practical matter too.
certain text editors can hit resource limits and
fall over or start behaving weirdly
(depending on things like syntax highlighting, or not).

without knowing anything about "format adapters" yet, nor defining what
"items" are, assume that files hold items and that each item takes
up one or more lines in the file. now, recall from [#852] that
although our entity identifiers can be of any hypothetical length,
each of its digits has a capacity of 5-bits (32 count).
we might call these "native digits".

skipping over some detail for now, we'll synthesize everything by saying
that we want to limit the number of items per file to some number that is
a _power of_ our "native digit" (of 32 values).
let's furthermore assume it's one-line-per-item.

so we want our item-limit-per-file to be something like:

  - 32^1 or 32 items
  - 32^2 or 1024 items
  - 32^3 or 32,768 items and so on..

as a purely axiomatic hack, imagine that 32 items sounds like too few to
have in one file. (we'll challenge this later.)

we'll say that
32 thousand lines sounds like too many to have in one file
given our objective of human readability.
(while editors _can_ still handle it,
empirically we know that this many lines gets cumbersome.)

so for now we have landed cleanly on the middle option: each file may not
exceed 1024 (i.e. 32^2) items.




## but what if you have more than 1024 items?

if we have more items than this items-per-file limit,
then we "scale" in an unsurprising way: we use multiple files.

these files live alongside each other in a directory. but (similar to the
items-per-file limit) we constrain ourselves to
a maximum number of files per directory
(explored in more depth in the next section).

with this "schema"
we find the item limit by
multiplying the max-items-per-file by the max-files-per-directory.

so if we need greater capacity still, imagine: items are in files, files are
in directories, and we'll keep a directory of such directories. again we are
self-constrained to some maximum number of entries-per-directory.

(we hold ourselves to the same maximum number of entries-per-directory
whether the directory holds files or other directories.
we could make the two numbers different, but why?)

if this still isn't enough, we can repeat this restructuring (adding another
level of depth) as many times as necessary to reach a capacity that satisfies
our projected maximum number of items.

the capacity grows exponentionally each time we
add another level of depth (or "recurse into the filesystem").
suffice it to say the practical limit on items
is not determined by the system's ability to
come up with new identifier-to-filesystem mappings.

(in theory this process of
adding a level of depth
to grow more capacity
could happen at runtime, but to implement such a feature
is well outside of our current scope, and
probably not the kind of thing we should be doing generally.)




## so what should the numbers be?

recall that we arrived at our item-per-file limit by considering what
amount of lines gets cumbersome. let's consider the powers of 32 again,
but this time imagining it for number of entries in a directory:

  - 32^1 or 32 entries
  - 32^2 or 1024 entries..

whereas 1024 doesn't feel like a lot of lines to have in a file,
it _does_ feel like a lot of entries to have in a directory
if we're looking at the directory listing in a terminal,
or looking in the folder in a GUI.

and along the same lines as arriving at other constraints, the determining
factor is certainly not from the filesystem. rather, it's an aesthetic
judgement (but don't worry, we'll challenge this later too).

putting this all together and skipping some proofs, imagine using this table
(where if your max number of items is X, do Y):

|for max of:|you _could_ do this:|
|---|---|
|1024 items|one file limited to 1024 items
|32,768|one directory with 32 files, each limited to 1024 items
|1 million|directory of 32 directories, each with 32 files, each with 1024 items
|> 1 mil|don't|

the above are examples of what we call "filetree schemas" or what we might
colloquially (and cheekily) refer to as "sharding".




## now imagine an alternate schema:

above, we tacitly assumed that each item occupied exactly one line.
(not having defined "entity" yet) now imagine:

  - each entity might span multiple lines (but don't go crazy)
  - so now let's limit each file to max of 32 entities

so:

|for max of:|you _could_ do this:|example path:
|---|---|---|
|32 entities|use one file|`items.foo`
|1024 entities|one directory with 32 files like above|`items/J.foo`
|32,768|one directory of 32 directories, each with 32 files, each with 32 items|`items/Q/7.foo`
|1 million|recurse the above once|`items/C/8/W.foo`
|> mil|don't

we haven't explained it anywhere, but note we have introduced the idea
of "paths" that identifiers somehow map to.




## bend the schema to design targets

we have come this far by steam-rolling over a bunch of assumptions and not
explaining details.

without having established it formally, we can infer that there is a suite
of related formulas with terms like the below as either inputs or
outputs as desired:

  - what's the average number of lines per entity we expect?
  - what is the maximum number of lines per file you're going for?
  - what is the maximum number of entries per directory you're comfortable with?
  - what is the maximum number of items we can hold?

you could target other constraints like:

  - how many levels of recursion is too absurd in a file path name?

so for example, let's say you're targeting one billion items (don't).
assuming the first schema introduced in this document,
this would mean paths that look like `items/A/B/C/D.foo`.

now, arbitrarily we could instead say that we are okay with 1024 entries per
directory rather than our initially proscribed 32.
(of course filesystems have no problem with thousands of entries per directory.)

given the other inputs, our paths would instead look like `items/AB/CD.foo`.

the point is these constraints all exist as a mesh of interdependent
trade-offs, as is often the case in engineering (indeed in creative
endeavours more broadly).

more to a practical point, there may be design targets we haven't thought
of yet, like:

  - maybe we shouldn't be concerned with number of lines but rather
    _filesize_ (as in number of bytes).

as is always the case, these decisions will have to be informed by what
our target use-cases will be.

  - if for example we will do some hack with grepping our data files
    (which we're considering for a project)
    we may want to play with the filetree schema to find one
    that is optimal for a wacky application such as that.

  - if (as we expect) we'll try something clever with VCS's,
    and furthermore we lean on it at runtime,
    there may be a sweetspot length of file we want to shoot for.




## so what the heck?

  - "types" are: bool, int, float, string etc.
  - an actual attribute is a name and a value (where the value has a type).
  - (attribute names have formal restrictions uninteresting here.)
  - we don't have formal attributes yet (that's "future feature 3").
  - an entity is:
    - an entity identifier
    - an ordered list of actual attributes (with unique names)
    - (and maybe forget the "ordered" part..)
  - about entity identifiers:
    - think of it as a positive nonzero integer <= some schema-determined max.
    - for practical purposes, think of the entity identifiers as always
      existing in their "encoded" form as lists of native digits, or better
      yet "identifier strings".
  - in their persisted state, entities live in files.
    very likely these files have a capacity of more than one entity per file.
  - "collections" are (er) collections of entities.
  - we may think of collections as being .. collections of entities of the
    same real-world "kind", or we may not.
    (maybe think of it like a typical RDBMS table. maybe not)
  - each collection has its own "filetree schema".




## what's a filetree-schema?

for the simplest practical schema ("32 cubed", introduced here) the idea
of a filetree-schema is one that would probably "click" for most people
simply by seeing a short example.

but here we give it a more theoretical treatment to provide a foundation
suitable for the imagined future timeline with experiments in particular
scale-ups and optimizations.

as we said above, entities are stored in files. put simply, one of the main
jobs of the filetree-schema is: given an entity identifier (string),
determine what is the file (path) the entity must live in.

for our first filetree schema, we are probably going to hard-code one
that is austere and consistent while still managing to have a capacity
suitable for an intended real-world use-case. (read from bottom to top):

    "B7F"
     |||
     ||\---> look for the entity with identifier "B7F" in that file
     |\---> in a file called "7.toml"
     \---> in a directory called "B"

for short we call this the "32 cubed" schema:

  - up to 32 directories (with names like "4" or "Q").
  - each with up to 32 files in it (with names like "5.toml" or "R.toml").
  - each with up to 32 entities in it (with names like "45B" or "QRX").

the 32 cubed filetree schema has a capactity of 32^3 or 32,768 entites.
(we might subtract one from this to avoid identifiers with an integer
value of zero just for superstition.)

if you run out of capactity, in theory it would be sort of trivial to
recurse a level of depth and for example become "32 quad", and get
a capacity of a over a million more entities. and cetera. but probably
even "32 cubed" will be impractically slow when run "raw" for most
queries, and "32 quad" exponentionally more so, etc.


again:

    "B7F"
     |||
     ||\---> look for the entity with identifier "B7F" in that file
     |\---> in a file called "7.toml"
     \---> in a directory called "B"

and then here's an imagined filetree (view):

    my-database
     |
     + database-meta.toml  # (don't know what would go here)
     |
     +- collections
         |
         +- artists/
         |
         +- songs
             |
             +- schema.rec  # (not specified (anywhere) what this is yet)
             |
             +- entities
                 |
                 +- 4/
                 |
                 +- B
                 |  |
                 |  +- 7.toml
                 |
                 +- Q/




## implementation decisions (all tentative)

  - in one imagined production release future timeline, each
    "mutable collection" will be a long-running resident of one daemonized
    service (perhaps each collection loaded lazily) but near term it would
    probably be unwise to implement towards this in our prototype phase.
    (but just keep this thought in mind as we implement things.)

  - but absolutely no caching yet! that's going to be a very last step,
    if ever. (should be compile-time plug-in, maybe)

  - because reads will be mostly uninteresting, we might just always say
    "mutable collection" when we mean “the collection [manager]”.

  - whether and when to break these different facets into their own modules
    will be an ongoing thing: filetree schema, mutable collection..




## freeform discussion

absolutely positively the implementation of "CUD+RT" at the collection-level
should have no knowledge of filetree schema hard-coded in to it. we won't
know the particular form this abstraction/separation/dependency injection
will take until we write it, perhaps.

we suspect that the filetree schema's main responsibility will be mapping
to-and-fro identifiers and file (paths).

somebody's gotta do locking eventually and that's absolutely gotta be write once.

then, while weighing all these things above, we also don't want to
over-abstract along the wrong dimensions at first (early abstraction)..

let's find the layers..




## (document-meta)

  - #born.
