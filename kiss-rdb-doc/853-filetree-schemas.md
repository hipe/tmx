---
title: filetree schemas
date: 2018-12-19T04:47:00-05:00
---

## why constrain ourselves?

recall from our README that a central design tenet is to be human readable
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

indeed this can be a practical matter too.
certain text editors can hit resources limits and
fall over or start behaving weirdly
(depending on things like syntax highlighting, or not).

without knowing anything about "format adapters" yet, nor defining what
"items" are, assume that files hold items and that each item takes
up one or more lines in the file. now, recall that from [#852] we like
our item identifiers to be made up of 5-bit (32 count) digits, which
we'll call "native digits".

skipping over some detail for now, we'll synthesize everything by saying
that we want to limit the number of items per file to some number that is
a _power of_ our "native digit" (of 32 values).
let's furthermore assume it's one-line-per-item.

so we want our item-limit-per-file to be something like:

  - 32^1 or 32 items
  - 32^2 or 1024 items
  - 32^3 or 32,768 items and so on..

as a purely axiomatic hack, accept that 32 items sounds like too few to
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




## (document-meta)

  - #born.
