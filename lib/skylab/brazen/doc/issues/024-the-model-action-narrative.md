# the model action narrative :[#024]

## :#note-70

if you override this method and result in a bound call from it you can
effectively short-circuit further processing while resulting in any
aribtrary result value from a surface component, even false or nil;
without beforehand knowing what the result scheme is from the surface
modality.




## #action-preconditions

see [#048] the preconditions graph for a (mandatory) introduction to
preconditions.

in its implementation the preconditions "pipeline" starts from the
action. the action will not get to its body of execution (the part that
you typically write) unless its preconditions are met.




## :#note-100

this method is named in accordance with [#hl-116]  ("shibboleth").
the selective listener proc that is our argument is from some outside
agent (like a top client of some sort).

this is the crux of making an event model with selective listeners: it is
this outside proc that gets to decide whether the event should even
necesarily be produced. but once we hear back a "yes" from this
callback, it is up to "us" to decide how the event is built.





## :#note-160

we break the event barrier here because we haven't designed a better way
around it.
