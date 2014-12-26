# workflow patterns :[#137]



## branch and divide :[#143]

(edit: this may duplicate somewhat something of below. we don't have time
 to read it just now)

when a changeset gets too big (for example because its scope is too big)
break it up into two smaller scopes in your mind, and decided which
should come first. make a branch from your last stable commit (where all
tests in some pre-ordained set of tests is passing).

using a compination of stash, stash pop, and your 'git-x'-style
interface, get *all* of the work into one or the other branch.

get the first branch green, then rebase the second branch over the first
(resolving conflicts as necessary) and proceed.




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
is a soft metal. but now that we have created this idiom we must run with it.
a compliment to [#136] the golden two-step, the golden plow is a differing
strategy with the some underlying goal: incremental stable changes.

whereas the two-step tries to isolate universe changes in their own commits,
the golden plow allows for small universe changes to be rolled into the topic
changes.

the rules of the golden plow are that each commit integrate with the univese
cleanly, so if you have to offline a subproduct because you are re-greening
it, you must "plow through" this process without turning back.

a golden plow may just itself be the first step of a two-step. so, with each
commit allow your universe changes to be rolled in to your topic commits, and
then when your topic feels like it is ready for some kind of integration with
a master-like branch, go back and re-write history to put all the universe
changes in separate commit(s).

one way this could be accomplished is by this:

• backup your branch

• if your golden plow chain is N+1 commits long, for each commit from HEAD to
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



## :#slow-step

step-debugging wherin you loop through the following steps:

1. set a breakpoint above the first as-yet-not-ran line you have written
2. step through each new line you have written until you find a line
   that either has an error or that you want to refactor for style.
3. if you found such a line in 2, stop the debugging session, move the
   breakpoint to above that line, and go back to 2.
   if not, then your test should be passing. write the next test and repeat.




## :#quarrantining-an-autoload-failure

### a case study

1. hopefully this starts by having one or more failing spec(s) from the
   universe.
2. write a test case in your topic node that produces the autoload failure
   by referencing the same node (const name) from (1).
3. effectively copy-paste the relevant graph into a fixture, but adding
   depth to its base and stripping out the body of the nodes as necessary.
   we give the new node names that are semi-regular transformations of the
   original names so that they don't interfere with refactoring yet have some
   bit of posterity and context (e.g "Erkshern" for "Action").
4. add a new test that looks exactly like the test case in (2) except change
   the names (and add depth as necessary) so that you are getting the exact
   same failure except from the fixture graph and not the universe graph.
   often rework of (3) is necessary to get the graph just right so it trips
   the same error.
5. with this "quarrantined" "bug" rework the topic code to fix it. sometimes
   we run all topic specs except the new specs we have added in these steps,
   to confirm that we are feature-adding without regressing.
   (and then we came up with #focus-not-focus for this step.)
6. confirm that you fixed it by running the test from (2), and either erase
   it or keep it for posterity (we would prefer that you erase it ultimately).




## :#focus-not-focus

you have a test suite for a node (let's just assume it is one spec file)
and you have written one test that fails (because either it's triggering
the topic bug or because it's triggering a failure related to the missing
topic feature).

add e.g a 'f' (focus) tag to that test. confirm that everything is green
except the topic by running all of the tests except the focus test (probably
just for that node), and possibly lock this down with a "work in progress"
commit. then as you work towards the topic (refactoring or feature adding
as appropriate), flip back and forth between the "focus" and the "not focus"
tests to make sure you don't regress.

for an aggressive refactor of a featurepoint that has code that is somewhat
#three-laws-compliant below it, it may be useful to use the experimental
'--too' option of quickie to run all tests the topic spec file up to and
including the test on a certain line: in this case let that line be the
line of the last test before the topic test that you presumably broke by
beginning this aggressive refactor:

the rationale behind this is that all the tests that came "before"
(or "under") the topic test should still pass because their correct
functioning should preclude the correct functioning of the featurepoint in
question; and if any of *those* tests is failing, you should fix those ones
before you fix any failing "outstream" tests (that activate functionality
that is presumably more complex than the "instream" functionality that came
before (or "under") it.
