## the API magic result shape narrative :[#021]

(see also [#041] magic property names)

in the purest pure model, the API emits only events and the client does
nothing else but effect behavior to express those events.

as it would turn out, it makes life a lot easier if we broaden this rule
somewhat. but first, more discussion.

events are nice as an idea because it is wide open: you can emit as many
events as you like and they can have arbitrary metadata associated with
them. however, when the client has some specific idea of what the
backend should be producing under normal circumstances, using these
events as the only substrate can seem clunkier than perhaps it need be.

one case in point is business entity streams. if you are presenting a
listing of some kind of business entity (e.g as an "index" screen, e.g
as search results), using events to express (or just wrap) these entities
can feel awkward.

so the topic is an experiment to this end: what if we say "if the API
call results in an object of a particular shape, effect a particular
behavior for that object."

anytime we write special logic around one such "magic" shape, we will
tag it with the node identifier of the topic.
