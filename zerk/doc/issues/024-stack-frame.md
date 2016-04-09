# stack frame :[#024]

## this document..

.. corresponds to the niCLI code node of the same name. for the agnostic
treatment of the concept, start at [#030].





## "why linked list"

like for the API modality here and for somewhere in
[ac], our parsing is stack-oriented both in implementation and in the
resulting representation. (and in this platform when we say "stack"
we usually implement it with an array.)

however, experimentally we are implementing the stack as a linked-list.
a property of this arrangement is that every stack frame can access its
0-N parents (that is, frames below it). as such, any top frame can
always access the whole stack.

this was useful when we were trying to get the top frame of the
selection stack to build the option parser; but as we are no longer
attempting that, this is now just an auto-didactic exercise, and a
safeguard if we change our minds back and attempt this again.




## on indexing, and avoiding the :#"heavy lift"

(for unrecognized terms below, consult [#030].)


### on avoiding the heavy lift

refer to [#ac-035] for the 4 (four) stage lifecycle of a node.
generally if we can keep a node in its earlier stages, less
resources are needed at the cost of having less detail about
the node. more detail costs more resources.

to index every node of every frame in a selection stack can be
a "heavy lift": the 3-normal shape is needed for each association
in the stack which requires that each of their formal nodes is
built which in turn involves loading each of their component
models, which may involve loading extraneous files. all of this
is resource-consuming work that can be avoided in some cases:

hypothetically for an invocation whose argument stream does not
appear to have options but only a trail to a formal operation,
*and* that formal operation does not have a "stated set", we
*can* avoid this heavy lift.

but are are some of the times we *do* need to:

  • when this invocation thinks it needs any option parser.

  • when the current token in ARGV does not resolve directly to
    one node, engaging the fuzzy matching facility.

for each of the above, here are the kinds of nodes they need:

  • option parser: the primitivesques.

  • fuzzy matching: operations, compounds.

(this may be effected further when we #mask.)



### on normal streams and the assymetry

to know the 3-normal category of an association involves getting it
to the third stage in the lifecycle (formal node). however; when we
have a formal operation, when it is only in its first stage we already
know its 3-normal category.

this means that while we *do* need to load the component models of
associations to "operation index" them, we do *not* need to load the
implementing resource of a formal operation (e.g a proc or a session
class). this is yet another potentially "heavy lift" that we can avoid.

an earlier go at this indexing involved having assymetrical streams of
these nodes: the formal operations in these streams where in stage 2
(they were node tickets), but the association nodes were in stage 3
(they were "associations"). however this approach gave us downstream
pain having to account for this assymetry in code, what with the
irregular meta-shapes of nodes.

_
