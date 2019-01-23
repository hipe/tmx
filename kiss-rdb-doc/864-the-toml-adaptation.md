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




## (document-meta)

  - #born.
