# what are puffers and when should you use them?

puffers are an experimental new way to extend modules. we don't know if
they're a good way.

as opposed to a module, which can be added to the ancestor chain of another
module with either `include` or `prepend`, a collection of method puffers
can give you more fine-grained control on what to do with a method definition
given whether that method may already be defined in the client module itself
or in its ancestor chain.

if this experiment proves useful maybe we will fill out this essay a little
more..

## when should you use them?

if you want to extend a client with methods that "play nice under composition"
..
