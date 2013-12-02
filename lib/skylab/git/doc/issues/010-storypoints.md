# storypoints :[#010]

# :#storypoint-1  introduction

the original use case of this application (node) has been obviated, however
it has not outlived its utility:

we developed this before we had a sufficiently deep appreciation for git's
usefulness to manage works in progress with branches. back then, a common
experience was to end up with multiple files that were not yet versioned.

the original problem this tried to solve was that we didn't like the feeling
of adding to our SCM "history" certain kinds of files: files in a half-
finished state, scratch-type files, one-off files, data files that only had
development utility for e.g.

to ameliorate this perceived problem we conceived that it would be useful to
have a 'git-stash'-like utility for unversioned files that operated simply by
moving the files over to a sister directory tree with the same structure (that
is, the "stash" directory tree would have a subset of the structure of your
project tree).

however the current thinking has become that the advantages of using git
branches for this outweighs any disadvantges when compared to using something
like 'git-stash-untracked'.

to the main point here, the reason we keep this 'stash-untracked' node around
rather than relegating it to SCM history is because it has a new
"value proposition" now:

this application node has a set of behaviors and "skills" that make it
attractive to stand as a model medium-sized general purpose utility:

 • it integrates with a tall stack of [#hl-069] "turtles".
 • it has multiple client layers that interface with each other (CLI and API).
 • it has a mostly standalone implementation for CRUD, for its "business
   entities": list, add, remove etc.
 • it implements a trivial but custom datastore (grafted on top of the
   filesystem).
 • it interfaces with an external service (namely 'git') - one that relies
   on underlying system interaction - to a somewhat non-trivial degree.

the above points cover a broad scope of the domain responsibilities of the
libraries, yet this application covers all of them without incurring a large
penalty of extra complexity beyond what is necessary to hit all of the points
above.

the act of keeping this application node healthy throughout the libraries'
evolutions in turn keeps the libraries themselves healthy: this application
serves only as a canary/benchmark: it only exists to go stale and then be
brought back to freshness such that the libraries exemplify a known scope
of freshness themselves, which is  the ultimate purpose of this node.


# :#storypoint-2  local idioms

defined loosely and for our purposes here we may define "application" as a
client that provides an interface to a set of actions. this particular
"application" is interesting because it exemplifies the "turtles" aspect
of application trees. we explore this idea futher in [#hl-117] what does
"application" even mean? ..


# :#storypoint-3  these constant assignments

the below sentence is being kept alive because it may be the historical first
stated occurence of the phenomenon now tracked by [#sl-123] #posterity.

doing these explicitly is actually less typing and less ambiguous than
including ::Skylab all over the place


# :#storypoint-4  the way sub-clients are used in this application

in the absense of any specific bundles being listed to be used for the
enhancement, we have found it useful for the enhancer to assume *almost*
nothing about what "sub-client" should mean.

we say "almost" because there is a figurative thread running through most
(not all) of the bundles' methods: it is the idea that the agent in question
has a reference to a "super-client" (that for e.g we store in an ivar called
e.g '@client') that provides services this agent needs in order to carry out
its execution.

note that there may be bundles packaged under the rubric of "sub-client"
that do *not* make this assumtion (although that in itself would be a nice
qualifier, wouldn't it?).


# :#storypoint-5 the sub-client implementation of the emitter methods ..

involves merely passing them through (delegator-style, hm..) to the client.


# :#storypoint-6 the default way to get an exg. for an s.c..

.. is to resolve the service


# :#storypoint-7 placeholder


# :#storypoint-8 these emit methods

emitter methods at the top-client level merely write strings out to the
appropriate stream. axes like "inner-string" are not a concern at this level.

just for #grease we test that [hl] gets this about to the write IO of the IO
adapter.


# :#storypoint-9 experiments with extensions

note how we corral *all* file-utils-related implementation into one location
in the file, even though it must touch several components. whether or not
this is overblown (it isn't), this is a model for our contemporary state-
of-the-art dependency injection. these are the model properties it exhibits:

 • top-down narrative: the bundle touch-point must be included before this
   point for reasons, otherwise it would be here. then the sub-bundles,
   then note that in the case of this extension, we put the stop-point for
   the service resolution in the API action. we weirdly combine the sub-bundle
   multiset and the IM module.

# :#storypoint-10 (placeholder)


(in the fire we lost [#hl-088], something about wiring)
