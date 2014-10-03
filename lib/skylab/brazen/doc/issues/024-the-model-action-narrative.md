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




## :#note-160

we break the event barrier here because we haven't designed a better way
around it.
