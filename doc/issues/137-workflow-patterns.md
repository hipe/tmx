# workflow patterns :[#137]


## the golden two-step :[#136]

this is an at-the-time-of-this-writing an imaginary maneuver consisiting of
this: in one pass you muscle through your topic, laying down a trail of
desctruction on top of stable nodes. you do whatever you have to do to get
your topic green while keeping the universe green.

then, the second step is this: you write your history to make it look as if
you did this in two steps: break out the part of the changes that have to
do with the universe, and then in one more commits integrate the changes into
the universe while keeping everything green, maybe even adding tests. then in
the second step you integrate your topic.

maybe this is only practical to do when you are re-greening a subsystem, as
opposed to maintaining it.

then in a subsequent commit (the "two" of the "golden two-step") you lay
down a commit (or more) that integrates your topic subsystem into the mix,
on top of the new universe changes you made.


### the point of this maneuver

the point is that it looks sloppy to have universe changes mixed in with
your topic changes. it is more courteous to the future to force this changes
into two or more steps, to make the narrative more clear.


### cons:

this will become a quagmire unless the scope of your step is relatively small.



## the golden plow :[#137]

in real life a plow made of gold probably would not be very good, because gold
is a soft metal. but we have started the idiom and now we are sticking with
it. a compliment to [#136] the golden two-step, the golden plow is a differing
strategy with the some underly goal: incremental stable changes.

whereas the two-step tries to isolate universe changes in their own commits,
the golden plow allows for small universe changes to be rolled into the topic
changes.

the rules of the golden plow are that each commit integrates with the univese
cleanly, so if you have to offline a subproduct because you are re-greening
it, you must "plow through" this process without turning back.

a golden plow may just itself be the first step of a two-step. so, with each
commit allow your universe changes to be rolled in to your topic commits, and
then when your topic feels like it is ready for some kind of integration with
a master-like branch, go back and re-write history to put all the universe
changes in separate commit(s).

one way this could be accomplished is by this:

• backup your branch

• if your golden plow chain in N+1 commits long, for each commit from HEAD to
  HEAD~N (that is, all of your commits in the chain), make a patch that has
  only your universe changes. (this step is itself a bit involved, but is left
  as an exercize to the reader).

• for the HEAD commit, you may skip this step if there are no universe changes.
  if there are universe changes in this commit: apply the patch in reverse and
  re-write the commit (so now the commit is only topic changes, and the
  universe changes are tucked away in a patch).

• for each commit from HEAD~1 to HEAD~N that has universe changes, do this:
  branch off of that commit, apply the universe changes patch in reverse,
  and commit this reversal ** in its own commit **.
  then rebase your work branch on top of this temporary branch and discard
  the temporary branch. then, finally, rebase your work branch by squashing
  this reversal commit into the one before it.

• finally, in a branch from HEAD~N-1 (which should be "STABLE", e.g master),
  apply and commit each of the univers changes patches in order. then squash
  them all together, see if it integrates cleanly, and integrate as
  appropriate. (remember per the rules of the golden plow, this *should*
  integrate clenaly without needing further work.)

• then finally finally, rebase your "work" branch on top of this new master.
  whew!

hm, not sure that was worth it. but mind you I haven't tried this yet!
