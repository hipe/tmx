# ACS construction, composition and eventing :[#006]

## :the-universal-component-builder

the associated codepoint is the normal, universal way we construct
a component for any purpose, be it unserialization or some first-time
construction like UI (edit sessions, reactive trees) or otherwise.

the primary purpose this node serves is to effect the call to the
component model's construction method (`interpret_component` or
related (:Tenet5)) or `[]` (:Tenet6). while there are other code locations
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
working with ACS's because of its primary design tenet: :dt1
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

this is in flux (but may become stable). at writing this dichotomy
is fresh, and is going thru its experimental "incubation" period.

two different event models have emerged "naturally" from the work.
some concerns are sensitive to which model is being employed.
to integrate these models into one unified model somehow would be nice,
but is outside of the current scope.

in the "cold" eventmodel, components are themselves not "bound" to a
custodian. we might call such a component a "cold-entity", meaning
it models business data and nothing else.

if the cold component exposes itself to operations in some way
(like an [#002] `edit` (mutation) method), it typically recognizes
a block passed to the entrypoint method, that will serve as *the*
handler for the entire (roundtrip, full-stack) execution of the
operation.

in the "hot" eventmodel, a component holds its "binding" (its
"listeners" proc) *as* member data. we might call such a component
a entity-controller or "hot entity". under this "hot" model, the
custodian typically passes the component a "special" event handler at
its construction time. then, when the component emits "signals",
this "special" handler routes each incoming signal to an appropriate
method defined *on* the custodian.

the benefit of the hot model is that the custodian can act as a sort
of "mapper" (like a filter) of the events its components emit, allowing
for some clever tricks with contextualizing events.

the cost of the hot model is that participating components are bound to
this one listener for the lifetime of the component, not the lifetime of
the action. the client cannot pass its own handler to such an operation
(unless a full component tree is built anew for each invocation) ..



### :#how-components-are-bound-to-listeners

from the codepoint, assume that every emission will have at least
one item (symbol) in the event channel. see next section.



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



### `mutated`

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
