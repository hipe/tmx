we chose toml over yaml because its forced simplicity and universality
is a good fit for the orientation of this project.

we think yaml looks nicer.

we aren't totally sold on toml.

we want to support different format adapters in a plugin way, etc.


## broad provision 1

it is certainly not the case that this is meant to work for all toml documents.
our variant of toml is stricter than the official spec to allow us to make
some cheats experimentally.




## broad provision 2

to make "crude" (fast) parsing easier on us, we are going to be very
line-centric. this means that for now multi-line doo-has may be out
but later for that.




## provision 2.1

when possible we will hackishly use the first character of the line to
determine what kind of line it is..




## broad provision 3

there's a time and a place for the many layers of validation that can be
done. for certain functions we're going to err on the side of doing things
the optimistic way unless strict validation is the objective of the
operation..




## provision 3.1

for a simple retrieval of the in-file attributes of an entity, we will
stop at the first matching section we find.




## future feature 1

the meta section




## (document-meta)

  - #born.
