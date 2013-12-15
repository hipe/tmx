# binary facet reflection :[#027]

Any given API Action instance either does or doesn't "have" any given facet.
In this sense each facet in its relationship to each action is binary because
we get either a `yes` or `no` for it.

For example, by definition, any API action that is implemented via a simple
Proc does not *have* the `emit` facet because by definition (and by design and
de facto) such an API Action instance cannot emit any events, nor can one such
API action (the formal one) declare that it emits any events. We could say
that emits nothing but rather we want to conceptualize it as meaningless
(or not..).

(likewise Proc actions do not have a `service` facet, for similar reasons of
de facto and de jure. however they *do* have a `param` facet, because Procs
have ruby parameters which we isomorph into API Action parameters [#015].)

for now, every facet is opt-in on a per formal action (think particular API
Action class) basis (exept Proc-based API Actions which may get the yes/no
for three facets hard-coded into them).

then, when the time comes to determine if a particular API action *has* a
particular facet, the way we determine this (for now) is that *either* on the
API action class *or* on the API action instance depending on the facet,
we call `has_foo_facet` on it, where `foo` is the facet name.

because facets are hard-coded [#028] we will for now hard-code the default
(t|f) for these values in the form of class or instance methods as appropriate
according to the facet; in the API Action base class!

~
