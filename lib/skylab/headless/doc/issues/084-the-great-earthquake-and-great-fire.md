# what is the deal with expression agents :[#br-092]

`Pen` (at this level) is an experimental attempt to generalize and unify a
subset of interface-level string decorating functions so that the same
utterances can be articulated across multiple modalities to whatever extent
possible..

HA I FOUND YOU

forgive the interjection, but i just found the initial trigger of the great
earthquake. AHAHAHAHAHA

INTERJECTION: this following thing we're about to explain to ourselves is
hilarious to us. we just found the initial trigger of the "great earthquake"
(which lead to the great fire)..

(EDIT: you may be looking for [#br-094] the real with with expression agents
if you mistakenly assumed that the title of this document reflected its
contents)

the uptake of all of it is this essay is shadowed by a same-titled one over
at [#br-093], "what is the deal with expression agents?". but what we're about
to say is more interesting to us..


## phase 1: exposition

what happened was, we started exploring the ideas therein while writing that
essay, and then realized how bad sub-client was in its current implementation
(and at some point wrote about how we are [#fa-030] trending away from
sub-client), and once we were convinced of how awful it was then we began to
rip it out of headless, wanting instead to propagate this bold new mechanism
of expression agents far and wide, replacing all this sub-client smell
everywhere (meanwhile being armed with this shiny new concept of bundles).


## phase 2: the excitement of a revolution

all of this felt fine and good, but how we went about it was a bit myopic:
because of how badly it broke everything and how poorly executed it was in
what turned into a foundational re-architecting of 30 subsystems and
applications in ~1250 files covered by 1700 tests, we were hobbled by our
own great ideas. we no longer had a green suite of tests to cover that
re-worked libraries were in fact sound, so we had to one-by-one "re-green"
each subsystem (starting from the smallest first), and at each step folding
in more and more changes to the battered and bloody headless. (actually
this process was kinda neat, it's why we are reworking tan-man, to make a
tool to assist with an operation like this.)

so this, then, is what is referred to when we say #the-great-earthquake:
re-architecting headless in this manner by ripping out the smelly yet critical
life-support system of the "sub-client" instance methods module, and in so
doing, sending a huge fissure tearing through the center of our continent.


## phase 3: the accident

but then the really stupid part was what caused the "great fire": all this
time all throughout the process of "re-greening" each subsystem, we were
so ashamed of what happened that we did not want to commit to the headless
subsystem in its half broken state because changes were quite radical and
ephemeral at this stage (when i look at the some of the early shapes of
bundles from my literal last commit i just laugh. one example: i basically
made an entire iambic DSL just to recreate the process of making a module
consisting of public, private and protected methods. i made a DSL for that.
what the actual..)

anyway it was shame like this that prevented us from feeling OK with
committing these intermediate snapshots to headless (which in hindsight was
outright stupid) (but note all this time we thought we might be able to
recover in a day or so, at first. just one more day...)

the coup de grâce came with this: at some point we forgot how unversioned we
were with a few huge critical files with changes in them (including a full
re-write of CLI action IM and most of the other big components) and we wanted
to do a 'git reset --hard head~1' for all the usual reasons that someone might
want to; but in so doing we forgot how unversioned we were. and that, ladies
and gentlemen, was how daddy burned the house down.

we 'git reset --hard' and all our unversioned changes were lost (duh). they
weren't even in history anywhere. it was as if we had done an 'rm -rf'. poof.
gone. it's really always that easy to lose everything.

the main thing we were doing all this re-writing for was now gone. it was
in fact a quite funny predicament to be in because we had this huge trail
behind us of green (having re-greened 18 or so of the subsystems around this
new and emerging headless) and then suddenly the floor fell out from under us,
and it was now as if all of this green had been built on a mirage.

so we did what any sane, pragmatic thinking first-person plural pronoun would
do: we girded our loins and started over.

that essay that served as the first harbinger of this great earthquake and
great fire, that was just over four months ago. i still have 12 commits
from the "headless earthquake" branch that i intend to patch over this new
headless, and i can't wait to get to them all.
