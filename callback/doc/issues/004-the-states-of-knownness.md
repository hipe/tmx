# the states of knownness :[#004]


## introduction

we love a good neologism and "knownness" is our favorite yet. this idea
grew out of [#ba-027] normaliztion and has since become both auxiliary
to that and its own thing.

for casual use we are keeping the name "trio" in some places, for both
its brevity and historical significance. however this tuple at first grew
to have more than three components and then fractured into a family of
closely related singletons and one class:

a "knownness" can be:

  • the "known unknown" singleton -OR-
  • a "known" instance

the first singleton and instances of the second class all answer the
question `is_known`. the first always answers the question `false`. the
second always answers the question `true`, *even when the known value is
`nil`*.


from any of these we can build a "qualified knownness". the qualified
knowness answers either some or all of the above questions, and also:

  • the `name_symbol` of the field (derived from the any "model" next)

  • the `model` of the field (see #intentionally-confusing below).


the fun of working with knowing what we don't know was the focus of the

this document was born from a cluster of work whose focus was to toy
with the idea of modeling formally "knowing what we don't know". in
fact, we experimentally added one more boolean field to manage trying to
model an unknown unknown until we realized that didn't make any sense
(see tombstone at the end of this file).






## intentionally confusing

in an earlier incarnation of this structure we called the component that
we now call `model` `property`. `property` was short for "formal
property", a concept that is now universally understood to us. this kind
of structure is universally understood as being a distinct ancilliary to
an "entity model" (which we call "model") for short.

the fact that this structure component is usualy occupied by a formal
property but is called `model` is knowingly confusing. all we can say
for now is that this choice in name represents a possible further
abstraction we may take in the future near [#br-089] the ACS.




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

the `is_known` field indicates whether the association exists
in the value collection. so for a "full" collection of knownness built
from an entity, the number of knownnesses will correspond to the number
of formal properties, and the number of those whose `is_known` is true
will correspond to the number of elements in the value collection.

now, of those that are `nil`, someone has to decide what `nil` means.
but we see that as a business concern outside of the scope of this
"knownness" structure.

_
:+#tombstone: when we used to have one more field, to model unknown unknown
