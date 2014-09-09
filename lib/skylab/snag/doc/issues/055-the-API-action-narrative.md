# the API action narrative :[055]

## introduction

we hate the old API action. it coupled tightly to the old pub-sub (now
[cb] digraph) and did other nasty things that we explore below.

so we started a brand new class `Action_` that is intended to replace the
old one. more precisely the two nodes will merge whereby we will keep the
history of the older one but use the newer name so that in the end we are
left with once class named `Action_` that does everything right yet still
works with the legacy actions.



## on the new architecture (what we have learned)

### API actions should emit structured data, not strings :#[061]

an API action that emits just plaintext strings can be silly because the
sexier of the types of clients we want to create can't really do
anything interesting with plain old strings.

this slippery slope lead us down to the +:[#hl-027] misfeature of the
"sub-client": each action had an entire suite of string rendering methods,
each suite tailored to the modality the agent was for.

one reason this was bad was because it didn't travel well: with this
approach we ended up wanting to render strings in more places than just
from the actions themselves (e.g auxiliary actors/agents). they too
needed to include this custom sub-client instance methods module in
their chain and it just got ugly because the sub-client module (both in
[hl] and in the applications) got muddied with far too many different
concerns, most of which weren't relevant to the domain of the class in
question.

we cut this gordian knot with 1) structured event classes in conjunction
with 2) expression agents. the action (or its constituent actors/agents)
need only send out to delegates structured event objects; it need not
concern itself with how to render them.

when the delegate (for e.g some kind of CLI invocation) receives the
event it may render it to for e.g a string using an expression agent,
but it is totally up to (and the primary concern of) the modality client
(or whatever auxiliary invocation agent) to determine what, how and
whether to render given an event.

different client of different modalities or purposes may implement their
own expression agents that effectively style and render the events.

(EDIT: The above would do well to go in [#hl-141] the expag doc node)



### bridging this gap: strings :#note-156

expression agents (as we've used them so far) provide a suite of methods
typically used in conjunction with message procs associated with events
objects to help turn those objects into their final rendered string form
to be used in those modalities that ultimately output strings.

since the API "should" emit only structured data and not strings, the
API "should not" typically need an expression agent, nor should it ever
be sending strings to delegates.

however, the scope at the commit at the time of this writing does not
include enforcing our "new" policy of emitting only structured data from
API actions (although that day is not far behind).

hence as a segway to our new utopia, we still use expression agents in
the API in conjunction with sending *strings* back to the delegates.

but (and this is my point) we write these string sending methods by hand
rather than expect that the API actions include e.g 'info string' and
'error string' in their list of channels.

but the real resolution of [#061] will involve removing all string
receiver methods from everywhere and needing to implement perhaps only
two string sender methods.




### bridging this gap: events :#note-136

in the new event model all of the callbacks ("channels") pertinent to a
given e.g action are encapsulated within a single delegate object, whose
only purpose is to hold this aggregation and receive events around it,
and send them out to somewhere else (or whatever).

in the old event model we would either treat the action object itself as
a delegate or one-by-one pass its callbacks as arguments to various
calls.

the newer way is better because separation of concerns.

to go from old to new we need to end up with an object that looks like a
new-style delegate but sends what it receives off to the old-style
handlers.



## legacy comments


### :#note-10

put `call_digraph_listeners` nearer on the chain than s.c above



### :#note-15

oh boy .. use the same factory instance for every action subclass
instance which *should* be fine given the funda-mental supposition of
isomorphic factories (see)
# **NOTE** see warnings there too re: coherence



### :#note-20

we check for unhandled event streams, but this line tells the validation
operation to ignore "tanonomic streams" like these.



### :#note-25

probably every API action subclass should have it in its graph that it
`delegates_digraph` this (and so it does) because we
`call_digraph_listeners errors` in `absorb_param_h` which they all
use (i think..)



### :#note-195

we override the one we get from [cb] to pass our factory 1 more parameter
than usual (the API action). whether or not this fourth argument is used
is up to the event factory.

(this used to be used to acheive the equivalent of "signing" and can
probably be factored-out).
