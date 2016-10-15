# README for development :[#007]

## objective & scope

this document is meant to be *short* and to serve as both a crashcourse
in our "architecture" and a roadmap overview of same.




## content

  - the architecture is architected around (legacy) [br] which it is
    straining from somewhat.

  - rather than being a toolkit for applying map-reduce operations to
    entity collections, currently this seems larely concerned with
    filesystem marshaling and unmarshaling.

  - we should move the three kinds of "functions" to perhaps a dedicted
    toplevel branch node `FunctionClasses_`

  - we kind of want to rename `Items__` to `Subclasses`, even though
    the latter name is not accurate in the platform sense.
