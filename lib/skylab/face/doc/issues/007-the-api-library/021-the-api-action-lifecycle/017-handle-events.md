# handle events

part of the "API action lifecycle" [#fa-021], `handle_events` is the
first hook-ish that is run with a newly created action on an execution
track.

our treatement of this currently is simply to hook the action out to any
modality client for *it* to manage event wiring. event listening is not
something that is currently deeply built into the API system as an integral
part of it.

the participating modality client will implement its own `handle_events`,
which may want to use "binary facet reflection" [#fa-027] to see that the
action `has_emit_facet`, and then somehow handle its events (possibly using
e.g the reflection API of PubSub [#ps-014]).

_
