# an introduction to regret

as the name suggests, you might really regret this. (this was [#ta-019].)

the Regret module is an alternate way to do something like rspec's
shared_contexts but with an implementation that is in some ways more
transparent and less opaque, while still in other ways being possibly
too opaque.

Regret represents a distillation of patterns and conventions that was
developed and refined while making the thousand of sprawling tests for this
and other submodules.

specifically, Regret is inspired by the fact that most of our TestSupport
modules have the following in common. every TestSupport module:

  • usually defines a ModuleMethods and an InstanceMethods (the module that
    has two above modules inside of it we refer to here as an "anchor module".)

  • has the usual implemtation of `extended` which is to include
    one and extend the other of the above on the extending module.

  • the M_M and I_M modules *always* include their "silhouettes" if any:
    if there is anchor module Foo and anchor module Foo::Bar, and each
    of these have an M_M and an I_M, then the deeper M_M and I_M *always*
    have the corresponding shallower ones in their ancestor chain, recursively
    upwards. don't expect to understand what this means until you need to.

  • sometimes wants to be some kind of autoloader, possibly with a
    `dir_pathname` that is customized in a consistent way.

  • 's InstanceMethods module responds to `let` in the r-spec way.

  • has a CONSTANTS module that forms a central place to hold business
    constants to help with running tests (usually at least the subproduct
    front module).

depending on the application/library being tested, a TestSupport module

  • might want to employ a tmpdir, named and sandboxed appropriately.

  • might want to invoke their API node using the appropriate 'SUT command'

  (these are hot-loaded extensions)

For our implementation of Regret itself as it will be used in the field,
we use the `embellish` (`[]`) method to enhance the topmost TestSupport
module in the subproduct.

To cascade the regretfullness downward at each successive level (directory)
in the test/ directory, nodes in the graph will call `edify` (also `[]`) of
the parent node, which is supposed to enhance the node appropriately.

for better or worse, the above steps have been repeated hundreds of times
in our test graph, in effort to provide some magic while avoiding other
magic.

_
