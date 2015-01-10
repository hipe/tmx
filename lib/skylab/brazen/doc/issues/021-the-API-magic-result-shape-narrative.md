## the API magic result shape narrative :[#021]

in the purest pure model, the API emits only events and the client does
nothing else but effect behavior to express those events.

as it would turn out, it makes life a lot easier if we broaden this rule
somewhat. but first, more discussion.

events are nice as an idea because it is wide open: you can emit as many
events as you like and they can have arbitrary metadata associated with
them. however, when the client has some specific idea of what the
backend should be producing under normal circumstances, using events as
the main substrate can get in the way.

one case in point is lists. if you are presenting a listing of some kind
of business entity (e.g as an "index" screen, e.g as search results),
using events to express (or just wrap) these entities can feel awkward.

so the topic is an experiment to this end: what if we say "if the API
call results in an object of a particular shape, effect a particular
behavior for that object."

anytime we write special logic around one such "magic" shape, we will
tag it with the node identifier of the topic.
