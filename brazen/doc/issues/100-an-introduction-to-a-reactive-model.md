# an introduction to a reactive model :[#100]
  ( formerly: "the client tree model"


## foreward

this document is a transplant from the sunsetting [hl]. we have made NO
effort yet to modernize it for what it means in the context of [br].




## older foreward

we're putting this down here now as a point of reference without intending
to articulate fully the tree model in its complete scope and vision, in
all of the glory and splendor it radiates. but here's a summary:




## TL;DR:

an application tree is just what it sounds like. but as a matter of principle
we try to blur all kinds of lines in terms of what it means to be a root node.
vs. a branch node vs. a leaf node; so tht we can build trees of trees, and
so on.

if nothing else, look at fig.2 of [#098], which is an ASCII drawing
of a client tree.



## ground already covered here

([#098] ouroboros ..)



## ground is already covered in [fa]

the "face" subsystem (a sister library that we are in friendly competition
with) has covered a lot of the ground for us, in terms of essay writing.
there are tons of nifty ASCII graphics to go along with them to, it is
a riveting romp not to be missed.

so first we will present a list of the relevant articles, and then we may add
some comments at the end (one day this will be arranged appropriately enough
into a grand tree of its own):

• really the perfect illustration for the client tree model is in fig.2 of
  [#098] "ouroboros and strange modules".

• [#bs-040] the matryoshka doll UI pattern is its own detailed spin on the
  tree model (all of which is relevant to here, because it has the exact
  some functional objective); and lays down some good general groundwork.


related articles:

• in [#bs-042] "this fun problem" we learn of way you can lock yourself
  out of extensibility with inheritence when implementing something like
  the tree model.

• in [#099.A] trending away from sub-clients, we whine about them there.

• [#093] "what is the deal with expression agents" discovers the big
  problem with sub-clients (as they were implemented) and tries to fix them
  and then makes a big mess. (our [#092] spares us no detail of the story
  of the great earthquake and fire that ensued.)