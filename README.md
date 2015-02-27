# Trackmarks

## synopsis

testing and metaprogramming experiments.

try:

    ./bin/tmx




## testing (too much detail)

the number of tests in this project ceilinged at 2796 tests in 427 spec
files before we made a concerted effort to simplify and universalize
everything.

on our typical mid-2010's development machine, running these tests all
at once takes a relatively long time (~ 78 seconds just now). this is
in excess of our self-imposed "breath" guideline (to be described
in [#ts-004] one day).

we infer that this is because the runtime reaches a "chokepoint" where
it is creating objects faster than it can de-allocate, and perhaps ends
up with memory islands, so it starts spending significanly more of its
cycles running the garbage collection routine but never releasing enough
memory to run as fast as it did in the beginning.

whatever the cause of these observed "chokepoints" is, running a
"long list" of tests takes significantly longer than it would to run them
in smaller "chunks" for some certain approximate size of "chunk". in effect
the cost of running all the tests becomes greater than the sum of the costs
of running its parts individually.

there is an ideal sweetspot where the number of chunks isn't too annoying
to run all "by hand", but still saves time over running all the tests at
once. our current such sweetspot has the total test time running at
15 seconds, which accords with our "breath" rule.

we make these "chunks" by grouping particular lists of sidesystems together
and running those chunks one at a time (currently 2 chunks). these
chunks are listed in GREENLIST.txt.

try:

    ./script/test-all -h



## Copyright

Copyright (c) 2011 Skylab, LLC. See LICENSE.txt for further details.
