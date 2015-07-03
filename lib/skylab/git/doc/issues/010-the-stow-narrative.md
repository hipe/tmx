# the stow narative :[#010]

## contemporary purpose

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
like the subject.

to the main point here, the reason we keep this 'stash-untracked' node around
rather than relegating it to SCM history is because it has a new
"value proposition" now:

this application node has a set of behaviors and "skills" that make it
attractive to stand as a model medium-sized general purpose utility:

 • it integrates with a tall stack of [#hl-069] "turtles".

 • it has multiple client layers that interface with each other (CLI and API).

 • it has a mostly standalone implementation for CRUD, for its "business
   entities": list, add, remove etc.

 • it implements a trivial but custom collection (grafted on top of the
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
of freshness themselves, which is the ultimate purpose of this node.




# :#storypoint-3  these constant assignments

the below sentence is being kept alive because it may be the historical first
stated occurence of the phenomenon now tracked by [#sl-123], which is
the now ubiquitous convention of maintaining our own sidesystem-local
constants:

doing these explicitly is actually less typing and less ambiguous than
including ::Skylab all over the place




(in the fire we lost old [#hl-088], something about wiring)
