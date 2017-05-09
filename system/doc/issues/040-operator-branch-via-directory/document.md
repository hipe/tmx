# operator branch via directory :[#040]

## intro & historical context

a hybrid amalgam of an older effort and a fresh, newer effort. the
older effort was once called "directory as collection" and was part
of the [br]-era "collection" proto-API. because of its strong
similarity to the now ubiquitous and superficially simple [#ze-051]
"operator branch" interface, we are altering the older API so that
it becomes a superset of (and uses the same name as) the newer
emerging API.

the older file assimilates the newer, but we use as a foundation
the newer code, only splicing in "grafts" of older pieces where
necessary. (this is why at #history-A we see what looks like a near
full rewrite of the asset node (file) and a deletion of another
asset node. what was deleted was the file that once held the newer code,
and the file that stayed saw a replacement of most older code with the
newer code.)

as a now historic experiment, the older collection exposed some
operations in compliance with [ac] interfaces for some of the
fundamental collection operations (add, remove) and that legacy
remains.




## implementation objectives

our main implementation objectives are to make this robust while
avoiding any extraneous "hits" to the filesystem. as a startingpoint
to imagine our implementation, we'll accept as axiomatic that under
"ordinary" operation we model the "resource" we get back from the
filesystem as a [#co-069] simple scanner. (in fact it comes to us as
an array of strings, but we don't exploit that structure as an array
directly [#co-016.1.5] for [#co-016.1.6] reasons.)

the implementation consequences of all this in descending order of
importance (most important first) are:

  1. only ever "hit" the filesystem at most once per operator
     branch instance.

  1. (as a corollary of above) when the scanner has exhausted,
     use the values of the cache (explained below) to produce a
     scanner when requested.

  1. (as a corollary of the first) at each advancement of the
     scanner (and mapping of its value (which turns path strings
     into "items")), cache the result of this map as the "item"
     that will forever after (for the lifetime of the subject
     instance) be used for the item at this position or retrieved
     by this key.

  1. hit the filesystem lazily (so not at subject construction time).
     (whether this ever actually saves a filesystem hit is purely
     a function of how the subject is used. since we often produce
     subject instances lazily, the answer is "probably not".)

the general idea of the above (of caching the items of a stream
(or in this case scanner) and exposing a random access for such
a cache) has an implementation at [#co-016.4].

as A) we suspect that the coverage we have given the subject is
already more complete than that of the referent and B) to attempt
such a leveraging of the referent by the subject is well oustide of
the momentary scope; such a refactoring is a possibility for the
future but not for today. (it may be good enough just to have a
"leash" on this work as being associated with this classification
of algorithms.)




## synthesis of the implementation objectives into pseudocode :[#here.C]

this state machine can only be understood (if at all) by reading
the below explanations in conjuction with the accompanying graph
at [#here.figure-1]

  1. we start out in an "initial" state, with no knowlege at
     all about where our scanner of items will come from.

  1. when any "point of defintion" comes in about same, we transition
     from the initial state to this "mutable" state. with each next
     "point of definition" that comes in, we feed it into this mutable
     structure meant to process these points. (we call this mutable
     structure the "implementng adapter" next.) this technique implicitly
     validates whether the kinds of definition points coming in accord
     with each other.

  1. whenever a first "read" operation comes in, we transition from the
     previous state to this immutable state, which flushes the scanner
     (only ever once) from the implementing adapter and perhaps hold on
     to an immutable structure that holds atomic values of points of
     definition for future reference by other pariticipants.

     to emphasize that this scanner (stream-like) holds resources that
     are only ever procured once per the lifetime of the subject instance,
     we sometimes refer to it as "The One" scanner.

     immediately, we check if the scanner is empty. if it is
     (if it started out as empty) then we transition to a state
     we will describe below. otherwise:

  1. we transition into this "pre-read" state where all the
     items are still represented in the scanner only.

  1. if ever a first read comes in, that is guaranteed to transition
     us out of this state. in all cases from here, we know we will need
     caching (because there will have been at least one item) so we go
     ahead and initialize the cache (hash) at this paranoicly lazy moment.

  1. the first read-advancement and each subsequent read-advancement of
     The One scanner produces an item (arbitrary business item) that
     knows its own locally unique "normal symbol" (name). this name is
     used to cache the item under for subsequent random access. we do
     so for each read-advancement until the last, which moves the subject
     instance into a frozen, "fully cached" state. whew!

despite how belabored it is, the above "state machine" doesn't even get
into how random accessing can move The One internal scanner forward.
at writing this may best be illustrated by the tests that try to explain
this interplay between random access and the internal scanner. also
[#here.E] gets into this important dynamic.




## about this one method :[#here.D]

in any filesystem that supports "globbing" (probably), if you
send a glob into the filesystem and get nothing back, you have no
indication of whether this is because the "startingpoint path" is
a directory that has no entires matched by your glob OR because
the path has no referent (i.e the would-be directory doesn't exist).

the subject method is for adding an explicit check first if the
directory exists before we glob against it. if the directory does
*not* exist, the subject emits a dedicated message explaining this.

in either case, results should generally be the same (empty stream
or equivalent) whether or not a missing directory is the cause of
having not matched files.

this facility is turned *on* by passing *falseish* (i.e if we
cannot assume the directory exists then we will check for it
first). sending trueish should have the same effect as not sending
anything, however for certain legacy use cases we have made it
assertively assumed that *something* (trueish or falseish) was
sent for this parameter, so that in effect the client must "sign
off" on the intended behavior one way or the other.

if you are "sure" the directory exists (or don't care to check),
then sending trueish here (or not sending anything at all when
appropriate) saves you one trip to the filesystem.




## about this other method :[#here.E]

produce a stream that can be used OUT IN THE WILD to stream over
the entire collection (i.e that any portion that has been cached
and any portion that has yet to be cached).

because this stream is resulted "out into the wild", once the
client has a handle on this stream she is free to send `gets` to
it any number of times (zero to infinity), each time occuring at
whenever or never.

between any one receiving of `gets` and the next (and as well in
the interim between when this stream is first built and its first
receipt of a `gets`), we must anticipate the fact that the
underlying state machine has advanced forward one or more states.

for one example, it's possible that during one of these iterims
a call to `lookup_softly` caused some or all of the as-yet
uncached items in the collection to be cached.

for another example, it's possible that during one of these
iterims other streams have been created and/or were iterated over
out of sequence with this one (but all coming from the same
subject instance).

as such we must implement this by producing results that are
sufficiently paranoid that the state could have changed out from
under us at any step; while being consistent per-stream and across
streams.

fortunately life is single-threaded, so we don't have to worry
about such issues during our `gets` call, but from one call to
the next we do. whew!




## #document-meta

  - :#history-A: this document's birth coincides with an event in
    the asset node described as referenced.
