# facets introduced :[#025]

a `facet` as it has come to mean in the context of the Face API API is a
particular "domain of responsibility" for the API as it pertains to the Client
(maybe modal, maybe amodal) and the Action.

its definition from "Faceted classification" (wikipedia) is just about on the
money:

  A facet comprises "clearly defined, mutually exclusive, and collectively
  exhaustive aspects, properties or characteristics of a class or specific
  subject"[1]

But for our purposes here we will maybe hold off on defining it too formally
until it has incubated somewhat..

[1] Taylor, A. G. (1992). Introduction to Cataloging and Classification.
  8th ed. Englewood, Colorado: Libraries Unlimited.


## but there are a few things we think we know now..

### every facet for now is hard-coded into the system somewhere

every facet is hard-coded into the system now somewhere :[#028]. at present
there is no way to load dynamically facets as if they were plugins. rather it
is a conceptual distinction we are making rather than a physical one.

however, we will make every effort to procede as if there were dynamic facets,
because that will probably become a thing, and even if no, it will still to
better, more comprehendable extensible software.

currently a subset of the facets corresponds to a subset of the states along
the lifecyle of an API Action [#021]; that is, they intersect.

If we had to come up with a comprehensive list right now of normalized facet
names that we know about and plan on using, it would look like:

  `call_digraph_listeners`, `service`, `param`

(but expect it to mutate and grow.)

note from the above list at least two things:

1) each item in the above list correspond to one *transition* in the API
Action lifecycle, namely:

  `call_digraph_listeners` corresponds to the `listeners_digraph` DSL method that defines the event stream
    graph for the API action, and which when listened to brings the
    action into a `wired` state.

  `service` corresponds to the `services` DSL method that defines the services
    the API Action (conceptualized as a plugin) declares as needing from its
    host, which when satisfied bring the action into a `plugged_in` state.

  `param` corresonds to the `params` DSL method that defines the parameters
    (conceptualized as fields) for the API action, which when satisified
    bring the action into an `executable` state.

2) each item in the above list corresponds to the relevant DSL method, where
we use the verb stem form (or singular noun if you prefer) of the DSL method
that is used invoke the facet enhancement [#026]; that is, the above
correspond to the DSL methods `listeners_digraph`, `params` and `services`. we
accidentally already demonstrated this in (1).

~
