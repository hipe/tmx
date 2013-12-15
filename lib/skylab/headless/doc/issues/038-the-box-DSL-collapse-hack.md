# the box DSL collapse hack :[#038]

(#parent-node: #040. this is a #storypoint there.)

(this documents relatively old ideas. we have edited it for maintenence and
 to aide in refactoring legacy apps etc. but note that these ideas pre-date
 whatever we came up with during the big rewrite of "legacy" (né "all.rb"),
 the "matryoshka" phase of Face, and this most recent re-write to "bleeding";
 all of which will certainly be legacy themselves by the time you read this.)

## understanding the hybrid architecture

this is the core of this whole DSL hack: our parent (module) node 'Box's has
a straightforward implemententation but we as DSL have two differnt jobs that
we dubiously confer on to one object: one is to act as a collection that
routes requests and/or does collection-related UI like render index screens
(this is the "box" part). the other is that once we have resolved for any
particular request one particular action, we provide the context in which
that action is executed.

this duality of concerns allows human clients to write one class that
has all of: each particular action isomorphing with each public method of
that class, and they may write private methods in the same class that do any
needed ad-hoc support (like method for building common options or doing common
normalizations, or routing to and wrapping to the API in a common way). for
better or worse each of these different concerns can be met by writing one
method (public or non-public) to one same class if desired.

## under the hood

for most of our utility applications this approach "feels good" on the
surface, is sometimes even fun, and produces utility applications that are
relatively easy to understand, maintain and modify (again, on the surface).

but under the hood is where it gets nasty: because of our arguably false
requirements we piled on to ourselves above, we have to have the same instance
acting as both a branch node and a leaf node (if it gets to the point of
resolving itself down to one action). but the branch node uses one option
parser, and the leaf node another. the branch node has one normalized
invocation string, and the leaf node another, etc. all of the code we write
to manage this "collapsing" feels wrong - especially when we need to pop
back out and act like a branch again, in the case of displaying some UI
invitation or something.

skim all of the blocky comments in the node to see significant evidence that
the current implementation is arguably unacceptable. what "feels good" on the
surface has an implementation that "feels awful." it is desire to narrow the
space between the feel-good surface and the feel-less-than-good mechanics
that drives us to write and re-write new solutions to this over and over
again.
