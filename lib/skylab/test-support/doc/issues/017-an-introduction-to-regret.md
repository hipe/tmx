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
pass your topmost TestSupport module to the Regret module itself thru its
`[]` method.

To cascade the regretfullness downward at each successive level (directory)
in the test/ directory, each successive TestSupport module downward will pass
itself to the parent node (also a TestSupport module) via the parent node's
`[]` method, which is supposed to enhance the node appropriately.

in practice this absolutely should *not* be in one file, but for a schematic
illustration of above, the below is an example graph illustrating nested
business modules with the appropriate test support module built for each
such module. for clarity we use fully qualified constant names where
appropriate.

    module ::MyApp
      module TestSupport
        Regret[ self ]
      end

      module Sub_Component_to_My_App
      end
      module TestSupport::Sub_Component_to_My_App
        ::MyApp::TestSupport[ self ]
      end

      module Sub_Component_to_My_App::Sub_Sub
      end
      module TestSupport::Sub_Component_to_My_App::Sub_Sub
        ::MyApp::TestSupport::Sub_Component_to_My_App[ self ]
      end
    end

above we have three business modules nested within one another matryoshka-
doll style. each business node has a corresponding test support node. note
however that the test support modules are nested matryoska-doll-style under
the topmost test-support node (which itself is nested in the topmost business
moduele); that is, each test support module is *not* nested within its
corresponding business node.

(not pictured is the useful content - the instance method module and module
method modules that we write under each test support node that have the
business-specific test support code.)

a condensed way of expressing this same taxonomy with two paths is:

  B1::B2::B3
  B1::T1::T2::T3

or as a tree:

  B1
  ├── B2
  │   └── B3
  └── T1
      └── T2
          └── T3

the reason that the test nodes are not nested under their corresponding
business nodes (except incidentially T1 under B1) is twofold: for one, almost
by necessity our module tree follows the filesystem tree; and the universal
convention seems to be to have a dedicated "test" (or "spec") directory per
project that holds all unit tests (as opposed to one "test" directory for each
business directory).

for two, some business modules have a sensitive namespace ("box modules"):
the constants that exist within these modules constitute a collection with
busines value. we can't have test modules coming in and polluting those
namespaces. also we don't want any autoloading hacks to cross-contaminate
the two domains (business, and testing).

..

for better or worse, the above steps have been repeated hundreds of times
in our test graph, in effort to provide some magic while avoiding other
magic.

_
