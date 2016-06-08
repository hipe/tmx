# the skylab "basic" sidesystem :[#020]

## objective & scope

this skylab sidesystem called "basic" ("[ba]") houses those general
reusable data-structures and simple behavioral classes generic enough
to be reused arcross skylab projects. examples are tree-ish and table-ish
concerns. (note that the *most* frequently used data-structures are
housed not here but in the omnipresent [co] for convenience.)

the namespace immediately below the "Basic" module is reserved strictly
for such structures & concepts -- generally they are nouns.

some such sub-nodes are more conceptual (for example there is a "List"
sub-node that has facilities useful for working with lists, however it does
not itself model a list structure); and others are more concrete (for
example the "Sexp" sub-node models an actual S-expression)
