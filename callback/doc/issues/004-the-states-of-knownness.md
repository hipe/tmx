# the states of knownness :[#004]


## synopsis

• a "known known" simply wraps a value. it can be a value of be `nil` or
  `false` (typically when these are valid values or the model), or any
  other value.

• a "known known" has the important side-effect that it itself is always
  true-ish (because it is an instance of a class we created).

• a "known known" can be "qualified" or "unqualified".

• the qualified variety of "known known" has an `association` field that
  must produce an assocation structure of any shape provided that it has
  a `name` field that produces a [#060] name *function*.

• the unqualified "known known" has no `association` field (and to
  request one should raise a no method exception).

• a "known unknown" itself does not have a value field. (however it is
  still true-ish like all "knownnesses"). because an unqualified known
  unknown has no internal state to maintain, it is a singleton object.

  EDIT: we can now construct a known unknown with a
  [#ze-030]#A "reasoning" object.




## prerequisites and side-reading

this is perhaps one step after [#fi-038] the meta-meta-properties
justification.

an important application of this "theory" at [#ba-027] normal
normalization.





## a "knownness" is our formal treatment of a "known known"

this is not epistemology - we are simply describing our data structures,
so hopefully we won't be here long.



### what is a "knownness"?

  • a "knownness" is the generic term for everything we are describing
    here.

  • a "knownness" is always true-ish. this fact can be leveraged by
    methods to result in a "knownness" on success and false-ish on
    failure when approriate.

  • a "knowness" can always answer the question "is this a known known?",
    that is, "is there a value associated with this knownness?"

  • a "knowness" can always answer the question "is this a qualified knownness?"
    (to be explained below.)



### what is a "known known"?

  • because it is a knownness, all of the above points apply to it.

  • a known known always has a value associated with it.

  • the value may be validly false or nil as appropriate.

  • in another incarnation we used the less opaque name "value wrapper"
    for this structure.



### what is a qualified knownness?

  • formally a qualified knownness is (either a known unknown or a known
    known) that also has an association structure associated with it.

  • because it is a knownness it can answer those points there.




## a short example:

there is a filesystem path with exactly three meaninful states:

  1) we know that nothing existed at that path
  2) we know that something existed at that path
  3) we don't know whether or not anything existed at that path

knowing that we don't know is crucially different than knowing that the
answer is "no": if we know we don't know, we must effect work. on the
other hand, if we already know the answer is "no", then to do this same
work again is a waste.




## shortwinded car analogy: known unknown vs. known known

if your headlights stop working on your car, you know you have a
problem. so we can say the problem is a "known" at this point.

you may suspect (as we did) that the solution is to replace the bulbs
(both of them, which oddly burned out at the same time). after you drive
to the car parts store (during the day) and get the lights and look up
on the internet how to replace them yourself and make an evening out of
it, the new lights you put in quickly burn out again after about 10
minutes of driving.

because you know part of the whole story (something about headlights
together with your car not working), but you know you don't know the
whole story ("why do they keep burning out so quickly?"), you know that
you don't know something. this state of formalized ignorance is the
central purpose of the subject library, and is what is meant by "known
unknown."

when finally you take your car to a *third* mechanic, and they finally
figure out as your dad suspected that it is in fact the alternator that
is causing the electrical problems, and this *finally* appears to solve
the problem, we can say that the problem is a "known known".




## longwinded kitchen analogy

imagine you are a server at a busy restaurant. you go back to the
kitchen to put your order in with the expediter. you politely scream,
"i need one small hot fudge sundae!!". the expediter asks "did they want
a cherry on top?"

(now, this analogy has some holes in it right off the bat: 1) most "busy
kitchens" are digitized now for this exact reason we will explore here.
2) usually it is waitstaff who build the desserts, not line cooks. 3) would
"a cherry on top" really be up for debate? but ignore all that for a second..)

so the question about the cherry is an inquiry as to the state of the
enduser's mind. do they want the cherry or don't they? clearly the
question itself is a boolean one (do they or don't they?), but in the
processing of it, there is *valuable* information here that takes up
more than one bit (a zero or a one) here:

the expediter shouts at you: "do they want a cherry or don't they?
WELL!? *do* they or *don't* they!? do you even *know*!??"

OK so the expediter may be exhibiting poor grace under fire on this busy
day, but the question stands: do you know whether they want a cherry or
not? so suddenly we have three (not just two) plausible and relevant
states:

  • you know that they want a cherry
  • you know that they don't want a cherry
  • you don't know whether they want the cherry

to put this in terms of the subject component, we can say that
"cherriness" is the "field" that we want to establish our "knownness"
of. in the first case, we can say that "cherriness" is a "known known":
you know whether they want a cherry and you know that they do. the
second case is also a known known: you know whether they want a cherry
and you know that the answer is "no". the third case is what we call a
"known unknown": you know that you don't know whether or not they want
the cherry. (but you know there is this thing called "cherriness" that
can be known.)

these states are important because they each correspond to a different
"correct" course of action: 1) put the cherry on. 2) don't put the
cherry on. 3) go back and ask the customer before you build the sundae.

even though the answer to the question can fit into a single bit of
space (yes/no true/false 0/1 etc), we don't always know the answer to
the question; and sometimes it is useful to represent *that*
information. sidestepping the issue of "fuzziness" (which is not yet
useful to us), the information of whether or not we know something
can itself be represented as a "yes"/"no" bit.




## more insanity

Remarkably, we don't end the insanity there. what's going on in the
*expediter's* mind? there are more than three significant states here:

  1) "i know that the server knows that they want a cherry"
  2) "i know that the server knows that they do not want a cherry"
  3) "i know that the server knows whether they want a cherry"
  4) "i know that the server does not know whether they want a cherry"
  5) "i don't know whether the server knows whether they want the cherry"

this may seem silly at this point, but there are actually five distinct
courses of action that correspond to these states: 1) cherry 2) no
cherry 3) ask server cherry yes or no 4) tell server to go ask 5) ask if
server knows (ok this is maybe the same action as in (3)).

the only reason we add this layer is to get to our last important state:
the perceived "knownness" in the mind of the server is (in our model)
being represented in the mind of the line-cook.

whether or not the server knows the cherriness (in the eyes of the
line-cook) is itself another boolean. we put this in terms of the
subject component:

  1) cherriness is a known known: the anwer is "yes"
  2) cherriness is a known known: the answer is "no"
  3) (cherriness is a known known .. hm ..)
  4) cherriness is a known unknown: there is no answer available yet
  5) cherriness is an unknown unknown. (but whether the server
     knows is an *known* unknown.)

and yes, you could continue this chain onwards infinitely. the kitchen
manager might be micromanaging, and might need to classify exactly that
state of cherriness for that dessert. the manager could know that the
line-cook knows that the server knows that the customer wants a cherry.

there's some formula to calculate the significant number of permutations
but we are going to classify this as a distraction for now..




## arbitrary?

given the above longwinded restaurant analogy, it may seem arbitrary
that we chose "one" for the number of boolean metafields, since it seems
like we could have maybe wanted two or three. (this explanation came
from back when we modeled the "unknown unknown". it may be less punchy
now.)

well here's the exact reason:

with this number of metafields we can model "isomorphically" and
losslessly all of the formal properties of an entity's model as well as
the actual values of the entity. we can do this just as easily if the
entity is represented by an object (i.e instance of the model class) or
in some other collection of values, like a hash, "iambic" array or
"box".

the `is_known_known` field indicates whether the association exists
in the value collection. so for a "full" collection of knownness built
from an entity, the number of knownnesses will correspond to the number
of formal properties, and the number of those whose `is_known_known` is true
will correspond to the number of elements in the value collection.

now, of those that are `nil`, someone has to decide what `nil` means.
but we see that as a business concern outside of the scope of this
"knownness" structure.

_
:+#tombstone: remove longwinded intro with some history
:+#tombstone: when we used to have one more field, to model unknown unknown
