# the definition and use of a mic :[#058]

(EDIT: deprecated..)

a `mic` (short for "microphone", pronounced "mike") is an object whose purpose
is to record the arguments (probably in the order in which they arrive) to
the successive calls to each of a set of particular methods.

in its previous incarnation this was called a `probe`. we were about to rename
it `recorder` for clarity, and then decided instead on `mic` for brevity,
provided that we formalize its definition here.

for a name we considered each of the four kinds of `test doubles` defined by
Meszaros [#sl-132] (dummy, fake, stub, mock); but none of these were quite
appropriate because they fit into the domain of testing whereas our whole
thing is a dubious DSL-ish experiment for production code.
