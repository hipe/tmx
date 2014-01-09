# the git repo narrative :[#011]

## introduction

because the repo is the frontmost object after the front, we will see a lot
of general higher-level notes here.



## :#as-for-grit

### historic original paragraph from the 'repo' node, before removing 'grit':

preston-werner, wanstrath, tomayko et al did all the hard work already with
grit so we keep it thin here. the purpose of this abstraction layer is for us
to give some thought about what our requirements are, if we ever decide to
target other VCS's like hg; and to insulate ourselves from implementations in
general.


### but then we were like:

at first it seemed flat-out ill-founded not to use existing solutions for
integration with `git`. but the ones we've seen did not meet our requirements.
furthermore grit's fundamental philosophy seems at odds with ours.

in the prototyping stages of this project we projected that we needed to
use three git commands (ls-files, log, diff) each particular options. grit
does not appear to implement a `ls-files`, and does not support the options
we need for `diff`. we didn't bother looking into `log`. also it triggered
several warnings of unused variables, also the "posix-spawn" library has
circular dependencies. we opted to do this "by hand" with system calls for
now, and then explore other alternatives in the future.


### snippet from the gemfile to integrate grit (here for reference):

    # gem "posix-spawn", "0.3.8"  # avoid circular, or not
    # gem 'grit'



## #what-is-the-deal-with-SHA's?

we suspect there will always be a better way to work with these unique
identifiers for commits. in the first prototype of this, passed SHA's around
as strings, because this was little more than a text processing hack. then
we starting to feel silly "wasting" that storage, so we started passing them
around as symbols, knowing the whole time that they are (seemingly) 40-byte
values, so passing them around as symbols seemed dumb to.

whatever the "ideal" way is to throw these things around, we will come up with
eventually but not today. as a perfect solution for such a perfect solution,
we simply make a wrapper class that manages a (possibly large!) field of
immutable singletons, one for each SHA. and then we just sit back and wait for
the future to tell us what is better.
