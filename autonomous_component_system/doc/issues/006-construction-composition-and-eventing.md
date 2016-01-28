# ACS construction, composition and eventing :[#006]

## :the-universal-component-builder

the associated codepoint is the normal, universal way we construct
a component for any purpose, be it unserialization or some first-time
construction like UI (edit sessions, reactive trees) or otherwise.

the primary purpose this node serves is to effect the call to the
component model's construction method (`interpret_component` or
related (:Tenet6)) or `[]` (:Tenet5). while there are other code locations
that "know" about these tenets, we want the subject node to be the
only one that *ever* calls these construction methods.

the successful result is a wrapped value (and never the component
itself) so that the true-ish-ness of a result can always indicate
whether the construction succeeded regardless of whether we are
dealing with a primitive-esque component.

this does not assign child to parent in any way, nor does it check
if there is already an existing child in any sort of parent member
"slot".

rather, what it does do it *bind* the component *to* the "custodian"
ACS. what we mean by "custodian" and "bind" is the subject of the
next two sections, respectively.




## why do we say "custodian" and not "parent"?  :avoid-saying-parent

we are familiar with the parent-child relationship in tree-like
data structures. ACS structures are frequently just that: trees.
however, we refrain from using the terms "parent" and "child"
(or even *thinking* of the components in this regard) when
working with ACS's because of its primary design tenet: :DT1
autonomy.

the whole theory behind The ACS is that if we strive to make
components autonomous, it will encourage decoupled design.
(and for now we leave an explanation of why decoupled design
is good to TODO link something).

for a component to know it has a "parent" (of a particular class,
let's say) will implicitly encourage a sort of dependency that
we don't want generally.

(for all but the most trivial ACS designs, component will often
need "services" (like access to a filesystem or application-wide
caches). this is a subject of exploration for [mt] that is currently
experimental..

(in the code we typically just say "ACS" to refer to the custodian
in a relationship.)

(TODO reasons)




## :#Event-models

at writing we have (thank goodness) simplified things so we only
have the "cold" eventmodel, and will perhaps succeed in re-writing
the "hot" eventmodel out of existence. we'll wait to see how that
goes .. (#during: [#010]) (EDIT:

this is in flux (but may become stable). at writing this dichotomy
is fresh, and is going thru its experimental "incubation" period.

two different event models have emerged "naturally" from the work.
some concerns are sensitive to which model is being employed.
at writing we are making efforts to integrate these two models,
but to be clear these two disparate models will never be "unified",
because they each have a distinct applicability.

in the "cold" eventmodel, components are themselves not "bound" to a
custodian. we might call such a component a "cold-entity", meaning
it models business data and nothing else (no event bindings).

if the cold component exposes itself to operations in some way
(like an [#002] `edit` (mutation) method), it typically recognizes
a block passed to the entrypoint method, that will serve as *the*
handler for the entire (roundtrip, full-stack) execution of the
operation.



### :#Hot-eventmodel:

in the "hot" eventmodel, a component holds its "binding" (its
"listeners" proc) *as* member data. this handler (proc) is an intrinsic,
unchanging member of the entity that is present for its lifetime.

we might call such a component
a entity-controller or "hot entity". under this "hot" model, the
custodian typically passes the component a "special" event handler at
its construction time. then, when the component emits "signals",
this "special" handler routes each incoming signal to an appropriate
method defined *on* the custodian.

the benefit of the hot model is that the custodian can act as a sort
of "mapper" (like a filter) of the events its components emit, allowing
for some clever tricks with contextualizing events.

(EDIT: the above is now seen as 'misleading')

the cost of the hot model is that participating components are bound to
this one listener for the lifetime of the component, not the lifetime of
the action. the client cannot pass its own handler to such an operation
(unless a full component tree is built anew for each invocation) ..




### :hot-binding

first off, if the component plans to emit no events then it need not
be concerned with any of this, but what's the fun of a component
like that!?

the component that might emit events needs to know of this interface.

assume an ACS instance that has exposed an edit method, and is using
this library method to implement it. if the edit session were to build
any components (which is what typically happens in edit sessions (for
adding and removing alike)), the custodian *might* want to give the
built component a "hot binding" so that whenever the component sends
signals to the custodian, the custodian can automatically see which
component is sending the signal without the custodian needing to be
aware this is happening.

(that is, the custodian builds the handler for the component. whenever
the component emits potential events into the handler, the custodian
may actually get an "enhanced" emission that also includes the
component itself, because of how the custodian built the handler
(typically by creating a "closure", as in [#]:codepoint-1)).

in order for the ACS to have this ability (i.e in order for this API
to support the possibility of this, regardless of what the ACS wants),
this call to the library method *must* take an `oes_p_p` - style block.

if the ACS uses a "cold" event model (where event handlers ride along
with operation invocations and not an intrinsic part of ACS's), then
it can do this but it still needs to honor the interface.

the inner-stream mutation session knows this interface..



#### :hb-again

assume an ACS *class* has exposed an `interpret_component` or similar
method, and is using this library method to implement it. in the exact
same way as above, the caller may want the component to bind to it via
hot binding.



#### the hot binding implementation explanation.

assume the ACS wants to build the component. the component typically
can't be built without being provided a handler: dynamic mutation of
handlers is something we just don't do. whether the component employs
a hot or cold event model, it will need the handler to be present before
the component can attempt to build. so: components can't be built
without the handler they will be built with.

with hot binding, the handler can't be built without a handle on the
component. in light of the previous crollary, it would seem we are
blocked by a circular dependency. it's sort of like trying to get a
job without experience, while and trying to get experiance without a
job.

so how we get around this is a bit complex: the ACS passes the
component model a proc that produces a handler, in exchange for the
component passing itself in as the only argument to that proc.




### :choice

at this codepoint, we send the modality-space handler to the call,
giving the operation a choice as to whether it wants to use it (cold
model), or use an internal handler that is part of its member data (hot
model). it is our way of sidestepping the issue here.



### :#ick

this tag tracks codepoints that were test that were written before we
discovered the distinction between hot and cold..




## (special-signals)

although we generally want every component to act as if it might
be the only component in a system, there are some special events
that are evolving in [mt] that only components emit, with a certain
shape. at present they are:



### `change`

the typical response for this is that the immediate custodian
"swaps out" whatever component (if any) is in that "slot" with
the component that is produced by the "event payload" of the event.
furthermore the implicit onus is on that custodian to produce
any informational emission about this event (for UI) and/or
propagate upwards the fact that something changed (typically for
serialization).



### `mutated` (:#Mutated)

this is for a component to tell its listener(s) that it itself
mutated. the payload is a linked list of context, terminating in
a structured event. a typical response by the custodian is to
propagate the signal upwards (perhaps adding context of its own),
or to serialize.



### `event_and_mutated`

(experimental, in [mt])




## universal trackings

### :#VP (1x)

this tag tracks the various similar (but never the same) implementations
of something like a polymorphic stream for one value.
