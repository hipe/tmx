# identifyings :[#038]

this intentionally awkward name is a project-local idiom,
and it's a solution to a problem.

an "identifying" is

  - of mixed type, typically it is either a string or a symbol

  - but the particular identifying will have a consistent type
    per what type of identifying it is


an "identifying" is *not*:

  - an "identifier" per se - that name is too ambiguous

whereas an "identifier" (probably) uniquely identifies a component, an
identify*ing* *probably* uniquely identifies a component but only in an
expicitly stated context.

so far, those types of contexts are:

  - the document (probably the test document)

  - the business branch (i.e "context")



## why?

the [#033] "fine and dandy" algorithm (which lies at the heart of
our synchronization algorithm, which in turn is really the heart of this
whole project), it has a robust simplicity about it, but it leaves
details unspecified about how we should deal with components other than
the two "components of interest", and how it should be applied to the
"depth dimension".

in order for the "fine and dandy" algorithm to work at the branch-level
(on the one hand) and on the document level (on the other hand), we have
to know what different kind of identifiers we are using for the different
components, and we have to know what we can expect of them in terms of
their supposed scope.



## what the heck do you mean by that?

these are the two types of "components of interest":

  1. context nodes
  1. examples nodes

it is only these two that can express a document-universally-unique
identifier. in fact this is the only criteria to be a "component of
interest" is that it can express a document-universal identifier
string.

these are the other main types of components that we work with:

  - a constant definition (a type of "shared setup")

  - a "shared subject" (currently the only other type of shared setup)

now, the participating asset documents, they can of course express
all four of these main types of components. furthermore our synchronization
algorithm relies on the idea that *any* of these components might stand as
a reference-point against which any *other* component might indicate its
placement.

so for example, typically we might define a const definition and then
one or more examples. it is certain that those exist in a context.

when the particular stream is being synchronized "into" the existing
document tree, it may be the case that the const definition is "found"
in the existing document but the example is not. in such a case (per the
fine and dandy algorithm extended to the dimension of recursive depth),
the synchronization algorithm has to "find" the existing const definition
(the first time when the document is indexed), and then be able to "find"
that node again when a mutable document tree is being mutated during
synchronization.

let's imagine instead that it is "shared subject" nodes instead that
are being referenced positionally. i.e, there is a new example node that
needs to be added immediately after an existing shared subject. how do
we "find" the shared subject nodes in the first place, and then how do
we find them again when they are referenced in this manner?


## properties of nodes, vis-a-vis identity

  - context node: we can assume a document-unique identifier.
    (see next item.)

  - example node: we can assume a document-unique identifier.
    (we can further assume that context nodes and example nodes
    share the same namespace, so we can resolve the node with
    only a string, regardless of what type of node it is, of
    these two types of nodes; given a single document.)

  - shared subject node: we can assume a *branch*-unique identifier. (:#note-1)
    that is, the same name cannot be used multiple times in the same
    branch, however the same name can be re-used in different branches
    in the same document. (when we say "branch" we mean context here,
    and we are referring only to the document node's immediate children,
    not all of its children recursively.)

    furthermore this is a different namespace from the "nodes of interest";
    i.e. a shared subject node may use a name that also exists as a
    description string for an example or context, and there is no conflict
    of name collision.

    how we refer back to shared subject nodes will be "annoying".

  - const defintion: we can assume there is only one const definition
    per business branch (i.e context node, immediate children only).

    how we refer back to const definitions will similarly be "annoying".
