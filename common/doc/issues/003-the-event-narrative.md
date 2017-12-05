# the event narrative :[#003]

## :[#here.B]

we have explicitly "disabled" the use of contructing events via `new`
because we to make it explicit that events are constructed in weird
ways, and we want you to consider that fact explicitly when you are
constructing them:

currently, to make the the business code "tight and readable" we want to
be able to construct events with literal iambics and have those "tag
names" manifest as attr readers (the way we are used to with structs).

the easiest way to do this is to hack the singleton class **for each
event that is constructed in this way**. this accomplishes the short
term goal stated above, but is not very elegant (see [#here.D] in situ).





## :[#here.C]

events should be thought of as immutable. if you want to change the
properties of an event for whatever weird reason, use this.

you cannot add new properties through this means, you can only determine
what the values will be in your new event of the properties that exist
in the first event. in order to add new propertes to a existing event,
you could perhaps use `to_iambic` and add new properties and value to
this array and build a new event from that.




# :[#here.D]

as available. your event's message proc must adhere to the set of
methods provided by the hard-coded expression agent used.




## :[#here.D]

this is really ugly and awful to have to mutate the singleton class like
this when you make a dup of an inline event. to support such an
operation without as much ugliness, consider making [#023] a dedicated
event class.
