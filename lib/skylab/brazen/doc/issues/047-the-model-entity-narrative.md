# the model entity narrative :[#047]

## introduction

we put the entity DSL to use to create all the business-specific (but
still very general) mechanisms of the brazen app. in turn, this node is
re-used by other apps.



## note-240

there is no known way around the fact that we must hold the state inside
the entity for whether or not this hook has been called: in the case
where multiple modules in the inheritence chain each add their own
required properties, if we don't hold this state then the hook is called
multiple times.
