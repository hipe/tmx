# workflow patterns :[#137]


## introduction

some of these are ancient and some of them may be brand spanking new. we
add the most recent ones at the top and give them the lexically greatest
letter of the alphabet.

one day we might break them into their own taxonomy because there are
some clear axes; like structurally higher-level vs. lower level, or what
kinds of development the workflows pertain to.

also it would behoove us to cull-out any workflows we don't use anymore,
with perhaps a retrospective analysis.




## CHECKLISTS



### when starting a new milestone:

  • search for all tags of milestone N



### before starting a new milestone:

  • search of all tags of N-1 milestone



### before/during committing:

  • rename goofy names to better names
  • todo's
  • turning on debugging lines in tests
  • breakpoint statements




## a practical development order for CRUD [#.H]

this is a fun one because it flies in the face of intuition. and like
[#.G] below, this one is *maybe* better documented in rough draft form
in commit messages (but we couldn't find any just yet).

first, let's consider an intuitive order before we present our argument
for the counter-intuitive order:


### the intuitive order (that's actually sub-optimal)

a "narrative" order for "CRUD" is suggested by the letters of the
acronym itself: you have to _C_reate something before you can do
anything with it, so it makes sense to do that first.

once you have created it you can _R_retrieve it. neck-and-neck in the
narrative ordering race is with retrieving it is _U_pdating the thing.

and finally, you should _D_elete it, but don't do anything after this
step because after you delete something you have nothing again.

this narrative justification is both cute and may have some practical
value. indeed we have written as much *maybe* in the commit messages
long ago.

HOWEVER we now have a stronger rational for a different suggested order:


### the counter-intuitive order (that's actually pro-optimal) is:

  1. list FIRST
  2. THEN retrieve
  3. THEN delete
  4. THEN create
  5. THEN update

the particular order is not as important as the rationale, and the
rationale is built on top of an axiom:

    the work progresses most optimally when the units of work are more
    or less of equal size.

we will offer no formal proof here of the above, but hopefully to some
extent it seems self-evident:

on the one extreme, if you have lots of units of work that are very
small, you "waste time" with the essential but perhaps tedius red-tape
of for example writing commit messages and running the test suite. no
matter how fast these processes are for you, you can probably imagine
a unit of work so small that it does not seem to justify cost (however
low) of this "red tape".

on the other extreme, a unit of work that is too big can make a project
come to an absolute standstill and/or cause integration headaches (or
even showstoppers) further down the pipeline.

it is the sweetspot between these two extremes that we are after, one
that (for appropriate use-cases) we try to formalize somewhat here.


### justifying our weird order

our order is based around introducing as little as possible new work in
each step, in a manner where that work that will be useful to have done
in one or more subsequent steps.

our order is based on a couple of general assumptions which you should
take into account as you consider the applicability of this order to
your silo-esque:

  • actions that mutate generally have more moving parts than actions
    that to not mutate.

  • generally, the more arguments an action takes, the more work it will
    be to implement that action. the more arguments you can process by
    re-using existing work, the more this factor is mitigated.

let's look at the order again, and we'll also add notation from the
perspective of mutability:

    1. list FIRST     - does not mutate
    2. THEN retrieve  - does not mutate
    3. THEN delete    - mutates the collection
    4. THEN create    - mutates an entity and collection
    5. THEN update    - mutates an entity

let's also look at the order in terms of the kinds of "arguments" that
are typically necessary for such "actions"

    1. list FIRST     - ~0 arguments (or some sort of collection identifier)
    2. THEN retrieve  - ~1: same args as above plus an entity identifier
    3. THEN delete    - ~1: exact same args as above
    4. THEN create    - ~many: same as (1) plus ALL required fields and etc
    5. THEN update    - ~many: typically the args from (4) plus (2).

in step 1 you get your head (and code) around the basics of working
with your datastore. also you have to get your entity class-ish working,
but only enough to list often only a single field from it (the
natural-key type field). and you're not mutating anything, so there
aren't as many "moving parts" (and points of failure) as there would
otherwise be.

in step 2 you implement the resolution of a single entity from an
identifier. you have at least two branches to cover here; the entity
may not be found. and you may get into working with particular fields
of your entity and displaying them in some read-only way. but again there
is no mutation yet; you have staved that off until..

step 3: deleting (to whatever extent you actually do this) is a step
that in practice is intuitively (or ostensibly pragmatically) saved
either for the end or for never. we think it makes the most sense to
implement the delete as the first mutating action because:

  • unlike the other mutating actions, the input argument to a delete
    action is typically a single "atom" of data - the entity identifier.
    less input data is less data to validate and less branches to cover.

  • for trivial cases the branches are binary-discrete: either the
    entity is or is not found. to cover and implement these two cases
    is less work than to cover all the typical branches in the other
    mutating actions.

step 4 is the first step where we may have to validate and normalize
the incoming data for perhaps many fields. it may be able to use aspects
of step 2, but this time the fields are editable as opposed to read-only
(as applicable).

as step 5 we put `update` after `create` only because this step 5 can
re-use a greater portion of the elements of step 3 and 4 than if we
changed the order: the `update` can re-use the entity resolution logic
of step 3 (for e.g the "entity not found" case), and as well it and 4
have obvious logic they will typically share.

yay!




## the 5-phase action implementation sequence :[#.G]

(this is better documented in commit messages currently..)

this is our favorite means of implementing a [br]-style model action for
any action that is at all non-trivial.

1. produce and write out the planned algorithm for the action's
   implementation in pseudocode (in a commited document). it is OK if
   this changes somewhat throughout the development, but typically a
   detailed enough pseudocode document will be protected from too much
   such violence.

2. decide how the pseudocode will be partitioned into roles and
   behaviors for actors, models and sessions.

3. one by one (at least one commit for each), implement each of the
   above. hopefully order won't be too important because hopefully there
   will be no dependency arcs.

4. synthesize the model action from these components.

5. do any integration with the action to the rest of the system and/or
   other modalities.

steps 3, 4 and 5 MUST have their own tests driving the development,
ideally in a three laws compliant way.




## branch and divide :[#143]  :+[#.A-F]

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




## "joggle"-ing

to "joggle" is our *triple* portmanteau of "jog", "toggle", and "juggle".

it was conceived of years after plow-named techniques described in the
next two sections after this one, and may or may not serve as a partial
or full replacement for one or more of them, or is perhaps oblique to them,
we are not sure which.

joggling is a bit like the [#127] three laws of test-driven development,
but instead of addressing the interplay between asset code and test
code, joggling addresses the interplay between a "library" asset node
and an "application" asset node.

the primary risk of joggling is early abstraction. somewhere in distant
commits and in one code location we speak of "perfect abstraction",
being (we *think*) what we now call "unification", that is, when you
distill a *similar* implementation of *two* or more application- or
library-like asset nodes into one library node. we call this "perfect"
because the redundancy of implementation stands as "proof" that the
would-be library asset has value in its would-be reusability. but
"waiting around" for this redundancy to occur when you are "almost
ceratain" that it belongs in the library node has a cost of its own.

joggling is an option for when you are integrating a library into an
application towards some end (for example a modality client). when you hit
a wall because of some feature you sort of assumed you would add to the
library, you (in effect) stash the applicaion work and add the feature to
the library node with its own coverage. this step gets its own commit with
*full* universe integration (i.e make sure the library changes don't break
anything).

when you "joggle back" to the application node it's OK to make small
changes to the library work too. (we have the luxury of allowing
integration to be a two-way street.)

one benefit here is the smaller steps you get of having commits that are
focused on one feature (being added to the library and being integrated
into the application (at whatever point in its story) variously). but
again the big risk here is swaying your library node into different
directions or adding complexity to it prematurely or extraneously.




## the golden two-step :[#136]  :+[#.A-F]

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




## the golden plow  :+[#.A-F]

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
  and commit this reversal *in its own commit*.
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




## :#slow-step  :+[#.A-F]

step-debugging wherin you loop through the following steps:

1. set a breakpoint above the first as-yet-not-ran line you have written
2. step through each new line you have written until you find a line
   that either has an error or that you want to refactor for style.
3. if you found such a line in 2, stop the debugging session, move the
   breakpoint to above that line, and go back to 2.
   if not, then your test should be passing. write the next test and repeat.




## :#quarrantining-an-autoload-failure  :+[#.A-F]

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




## :#focus-not-focus  :+[#A-F]

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
`#three-laws-compliant` below it, it may be useful to use the experimental
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
