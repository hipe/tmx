# the greenlist divvy cost algorithm :[#009]

this was the ultimate replacement for GREENLIST (that which
catalyzed this whole crazytime rewrite of tmx): break up the
nodes into N (user-chosen nonzero positive integer) process-
plans using (imaginary at first) "costs" (or a costsk file),
where "cost" could be e.g milliseconds it takes to run all
the tests in a given node:

 1. sort all the nodes descending by cost. (nodes that take
    the longest to run their tests are highest in the list.)

 2. divvy them into N buckets like so: whichever bucket has the
    lowest total at the moment gets each next node. in the case
    of a tie chose the leftmost (lowest-numbered?) bucket because meh.

 3. (select the Mth bucket if you are only running one)

 4. order the items in the bucket by regression order (fwd or
    backwards based on troubleshooting mode or fail-earlier mode)
.
