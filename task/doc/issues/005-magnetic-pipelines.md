# magnetic pipelines :[#005]

every function defines itself in terms of *one* or more formal
argument nodes and *one* or more formal output nodes. the output node
of one function can serve as the input node to another, and so on.

in order to solve a function, every one of its arguments must be
solved. (i.e, arguments are never optional.)

likewise if a solved function is called it "guarantees" that it will
produce *every* one of its output nodes.

the output nodes are quite like return values. it's not a rule but
in practice functions often define only one output node (but that
node may certainly be the output of more than one function).

yes, this is a circular definition (functions are defined by nodes
and nodes are produced by functions) and yes, there is danger in
cycling. a safeguard check is in place but we will not fail
gracefully. don't cycle your graphs.

"endpoint" nodes are nodes that are nobody's input, and "startpoint"
nodes are nodes that are nobody's output. together they comprise the
"terminal" nodes of a pipeline network ("graph").

in fact a graph is just a "view" on a set of functions that define
themselves using shared pool of node names. a function's "signature"
*is* its name and its name (for most purposes) *is* its identity.

a corollary of this is that no two functions can have the same
signature. but because this is often a useful pattern to employ, you
can achieve the same effect by introducing another parameter whose
only purpose is to indicate which function to call, and then
introduce a function that consumes this parameter and calls
the appropriate function. (this is the fledgling "select" pattern
pattern (EDIT).)

this design is limiting but also liberating: a problem can be solved
by such a "pipeline" if given your input arguments you can determine
a deterministic




## "contrived example" illustratting the permutation problem

imagine you are trying to get from DC to NYC. there is no direct
arc from DC to NYC. but you can get from DC to philly and from
philly to NYC. now, you can either bike or walk from DC to philly,
and you can either swim or fly from philly to NYC.

so, the actual possible routes here are:
  - bike, swim
  - bike, fly
  - walk, swim
  - walk, fly

(EDIT)
