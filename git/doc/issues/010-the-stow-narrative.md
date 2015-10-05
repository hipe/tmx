# the stow narative :[#010]

## introduction & intended value

when we first wrote this utilty, `git-stash` didn't have the
`--include-untracked` option. from a purely funtional standpoint, the
use of that option is similar enough to the "value proposition" of this
whole utility to such an extent that it makes this whole utility seem
entirely obviated.

however, A) over time, the deeper value to this utility would emerge as
a well-rounded canary application; big enough to do lots of differnt
important kinds of stuff, but not so big that it is heavy. (we explore
this in the next section).

and B), we still can't shake the OCD feeling that when faced with a
bunch of unversioned files (perhaps in a structure that is itself not
yet versioend); there are or will be times when we would rather just
move the files over (structure intact) to a directory outside of the
project, and later just move them back, without having to worry about
our history graph and any merge conflicts.


## actual value

what this utility has is a set of skills that makes it a dream for
testing frameworks and testing facilities (i.e meta-testing): it
implementation surface area is near perfect in that it touches a lot of
different kinds of mechanisms used by bigger applications without being
a bigger application itself:

  • it does or will integrate with a [#br-098] "tall stack of turtles".

  • it does or will have a non-trivial modality-specific implementation
    ("client") that talks to a modality-non-specific "reactive model"
    backend ("server"). indeed, at writing there are still some
    outstanding design issues in regards to this (near colorization
    of tree-stats, etc).

   • it implements a trivial but custom collection (grafted on top of the
     filesystem).

   • what it does along CRUD is representative of most of our applications.

   • it interfaces with an external service (git), for which we must
     interact with a system in a somewhat non-trivial manner.

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




