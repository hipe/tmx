# eventpoint :[#004]


## quick preface to this document.

we merged [pl] "digraphic" and [ta] "eventpoint" so that we would have
a single, central facility for this kind of pathfinding. this document
was originally part of the remote side but then moved here during
 #tombstone-A.




## general algorithm :#storypoint-01

we are at the 'started' state. we need to get to the 'finished'
state by finding a fitting sequence of hypothetical state
transitions. these hypothetical transitions are bound by the
particular combination of:

  • the "digraph" (directed graph) formed by the application's
    formal state machine
  • the capabilities of the various plugins
  • the particular input arguments

such a series of hypothetical state transitions is called a
"plan". if a plan cannot be found from start to finish given
the digraph and the input, then the result is the "unable
case" (:1 of N).

(EDIT: we might now call it "path" not "plan".)

in any "unable case" the dispatcher emits to the selective
listener callback the possibility of zero or more events
expressing details of the inability, and it results in the
unable value (probably `false`). this occurrence does not
reach the plugins themselves.

if a plan *is* found but there are input elements that would
never be processed during the course of executing the plan,
then this is also classified as the unable case (:2 of N).

a plan is a series of steps, each step changing state until the
final step (whose final state is always `finished`). at each
step *exactly one* plugin must be resolved to change the state.

if a plugin is not found to change the state at this step then
this is classified as the unable case (:3 of N, which may
or may not end up as the same logic for 1 of N).

if more than one than one plugin is found that can change the
state at this step then this is an unrecoverable ambiguity (even
if they all would transition to the same next state), also the
unable case (:4 of N).

steps are added to the plan successively in this manner until
either inability is detected or the finished state is reached
by the plan.

it is hypothetically possible for this process to repeat
"inifinitely" without ever reaching the 'finish' state (for
example by what amounts to an inifinite loop of traversing
part of the graph in a circuit (or figure 8 or whatever).

the means to protect against this is a well-formed directed graph
that ensures state transitions always go "towards" the finish
and never away from it. that concern is outside of our scope.

we may make further provisions for no-op state transitions:
that a plugin would be able to effect a transition whose end
state is the same as the start state, but to allow this "safely",
it may be that the dispatcher when encountering a plugin that
effects such a transition removes a plugin from consideration
for the next step, so that any same plugin may loop-back to the
same state only once.

the act of building a plan and the act of executing the plan are
done in discrete sequential steps (here at least).




## #storypoint-11

with every option that every plugin can parse, do a "canary pass"
whose purpose is only to determine what transitions are activated
at each step: in one parse we will gather all the data to decide
each step (because the criteria for determining transition activiation
is fixed and decided by the dispatcher).

a corollary of this is that at this moment we will bork on
unrecognized opts. do not mutate the original argv but a copy which
is held on to. for each option that is parsed hold onto the fact that
it is parsed and the array of args passed to its callback (zero or
one arg).




## understanding the model: agent profile

what we call an "agent" is (EDIT)

=> agent profiles are not agents




## #storypoint-21 - "canary parser"

we will iterate over every formal option of every state transtion of
every plugin. but first, what is our 'SLC' list?

a list of "short-long-combinations" is maintained. conceptually, an
SLC is the essential "equivalency identity" of an option: it can be
thought of as the identifer strings for the one or more of [the zero
or more short switches and zero or one long switch], along with
the argument arity of these. in practice we store only the first
formal option encounted for any given SLC:

each SLC is cross-referenced by its every short identifier string
and any long identifier string. with every formal that is encountered,
do a lookup against the existing SLC indexes to produce a list of known
SLC's that have one or more of [short or long] identifier strings
in common with this formal:

if no existing matching SLC's are found, add a new SLC reflecting
this formal, being sure to index it into the two indexes for the above.

if more than one existng SLC is found, then this formal is not valid
in this plugin constituency because it matches more than one
existing formal. fail expressively.

if (finally) exactly one existing SLC is found, produce the difference
of this formal against the other, i.e any meaninful essential value this
one has that the other one doesn't. get the coverse difference
too (what does it have that this one doesn't have?). with the
any-ness of these two differences, respectively:

      - -  you and i have no differenes. you can represent me.
           when you trigger i may also trigger. do nothing:      OK

      - Y  you have something i don't (you're more specific).
           you cannot represent me - you might trigger me in
           cases when i otherwise wouldn't:                     FAIL

      Y -  i have something you don't (i'm more specific). for
           the same reasons as above, i cannot represent you:   FAIL

      Y Y  we both have our differences, this cannot work:      FAIL

    whew.

OK, now that we know what an SLC list is: for each formal option of each
state transition that each plugin can effect,

  • if the formal has no long identifier and no short identifier as found
    by our hacked peeking, then it is a formal option we are unable to
    process through this algorithm. the entire canary parse cannot procede
    robustly. fail expressively.

  • reconcile this formal against the SLC list as descirbed above,
    failing and/or mutating the list and indexes as needed.

  • memoize the "occurrence" of this formal option as a function of
    the plugin index, what transition it is for (symbol name) and whether
    it is catalyst (or an ancilliary). this structure goes into a list
    of occurrences. the occurrence will know its own index in this list,
    which we refer to as the "occurrence index".

once that pass is complete, we build a derived, compound option parser
from the SLC list. each block for each option definition will take or
not take an argument as determined by any long or first short option in
the definition args.

this block will yield to [ somewhere ] the value (when appropritate) and
the relevant occurrence indexes. HERE





------------------------------------------------------------------------------

## (posterity)

"couduit" is the working title of this essential two-way structure. the
shell both models services that the plugin needs from the host, like a
stream to write info messages to, or perhaps the higher-level "info yielder".
beyond these basics, the host is invited to subclass and customize this shell
class as necessary. (kick the class with the `plugin_conduit_class` class
method on your host.)



## document-meta

  - :#tombstone-A: merged [pl] "digraphic" with [ta] "eventpoint". lots of sunset.
