# an introduction to regret :[#017]

as the name suggests, you might really regret this. (this was [#tm-019].)

the Regret module is an alternate way to do something like rspec's
shared_contexts but with an implementation that is in some ways more
straightforward, orthogonal, transparent and opaque; while in other ways
possibly beign too opaque, unless you really study this document.

Regret represents a distillation of patterns and conventions that was
developed and refined while making the thousands of sprawling tests for this
and other submodules over multiple years.

specifically, Regret is inspired by the fact that most of our TestSupport
modules have the following in common. every TestSupport module:

  • usually defines a ModuleMethods and an InstanceMethods (the module that
    has two above modules inside of it we refer to here as an "anchor module".
    elsewhere it may be referred to as a "test node module".)

  • has the usual implementation of `extended` which is to include one and
    extend the other of the above on the extending module.

  • the M_M and I_M modules *always* include their "silhouettes" if any:
    if there are anchor modules Foo and Foo::Bar, and each of these have an
    M_M and an I_M, then the deeper M_M and I_M *always* have the
    corresponding shallower ones in their ancestor chain, recursively
    upwards. don't expect to understand what this means until you need to.
    see "considerations when nesting" below.

  • the test node module often wants to be some kind of autoloader, possibly
    with a `dir_pathname` that has a certain idiomatic customization related
    to the fact that our root test node module in a project always has a const
    name of "TestSupport" but it always isomporphs to a corresponding directory
    called "test" (and not "test-support" or "test_support"). :#storypoint-35


  • the test node module's InstanceMethods module responds to `let` in the
    r-spec way.

  • the test node module has a CONSTANTS module that forms a central place to
    hold business constants to help with running tests (usually at least the
    subproduct front module).

depending on the application/library being tested, a TestSupport module:

  • might want to employ a tmpdir, named and sandboxed appropriately.

  • might want to invoke their API node using the appropriate 'SUT command'

  (these are hot-loaded extensions)


## an introduction to usage

For our implementation of Regret itself as it will be used in the field,
send `[]` to the Regret module itself with your topmost TestSupport module
as its only argument.

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
module); that is, each test support module is *not* nested within its
corresponding business node.

to see this same graph a different way, imagine that that modules are folders
which can be inside one another (indeed a strong isomorphicism). imagine that
our application is called "truncheon", and it has a node (a module or class)
called "IO_Stream", and inside of that is a more specialized node called
"Socket_IO_Stream".

    +------------ Truncheon  -------------------------------+
    |                                                       |
    |  +-------- IO_Stream -------+                         |
    |  |   +-------------------+  |                         |
    |  |   | Socket_IO_Stream  |  |                         |
    |  |   +-------------------+  |                         |
    |  +--------------------------+                         |
    |                                                       |
    |  +------------- TestSupport ------------------------+ |
    |  |                                                  | |
    |  |   +---------------+  +-----------------+         | |
    |  |   | ModuleMethods |  | InstanceMethods |         | |
    |  |   +---------------+  +-----------------+         | |
    |  |                                                  | |
    |  |   +--------------- IO_Stream ------------------+ | |
    |  |   |                                            | | |
    |  |   |    +---------------+  +-----------------+  | | |
    |  |   |    | ModuleMethods |  | InstanceMethods |  | | |
    |  |   |    +---------------+  +-----------------+  | | |
    |  |   |                                            | | |
    |  |   |    +-- Socket_IO_Stream ---+               | | |
    |  |   |    |                       |               | | |
    |  |   |    |  +---------------+    |               | | |
    |  |   |    |  | ModuleMethods |    |               | | |
    |  |   |    |  +---------------+    |               | | |
    |  |   |    |                       |               | | |
    |  |   |    |  +-----------------+  |               | | |
    |  |   |    |  | InstanceMethods |  |               | | |
    |  |   |    |  +-----------------+  |               | | |
    |  |   |    +-----------------------+               | | |
    |  |   +--------------------------------------------+ | |
    |  +--------------------------------------------------+ |
    +-------------------------------------------------------+


To restate, the above is three business nodes nested inside of each other
"concentricly", and then three test node modules similarly nested inside
of each other, with the first such test node nested inside of the root
business node. in discussion of this below we will omit discussion of the
"InstanceMethods" and "ModuleMethods" modules.

this same taxonomy can be expressed (perhaps in its most condensed form)
with two paths:

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



## considerations when nesting

for any test node module "Foo::Bar" that is inside test node module "Foo",
under the regret system its instance methods module, module methods module,
and constants module will each necessarily add their "silhouette" modules
tho their anchestor chain:

      +----------------------------+
      |            Foo             |
      |          +-----------+     |    +-----------------------------+
      |          | Constants |  <----+  |          Foo::Bar           |
      |          +-----------+     | |  |    +-----------+            |
      |                            | +------ | Constants |            |
      |  +----------+              |    |    +-----------+            |
      |  | M.M's    |  <-------------+  |  +-----------+              |
      |  +----------+              | +-----| M.M's     |              |
      |                            |    |  +-----------+              |
      |       +------------+       |    |             +----------+    |
      |       | I.M's      | <------------------------| M.M's    |    |
      |       +------------+       |    |             +----------+    |
      +----------------------------+    |                             |
                                        +-----------------------------+

so the general rubric here is, don't push thing up to "Foo" unless it is
needed by "Foo::Bar" and all of Foo's other children and sub-children.
both quickie and r-spec implement test contexts as classes so you can always
write whatever constants and methods you need in the test context itself
and it won't "pollute" this graph.



## why we do not include parent anchor module :[#016]

*note*: we do *not* include the parent_anchor_module itself into this client
anchor_module. if you do, with our chosen naming convention (which seems vital
and fixed at this point) it will have the effect of having the test-support
anchor modules masking the client modules of the same name:

  e.g.:  MyApp::Mod_1                      # business logic for your app
         MyApp::Mod_1::Mod_A               # this holds some sub-content
         MyApp::TestSupport                # your root test support mod
         MyApp::TestSupport::Mod_1         # test support for same
         MyApp::TestSupport::Mod_1::Mod_A  # test support for same


if you are either directly "inside" TS::Mod_1::Mod_A or you are in a module
that has included same, and you say `Mod_1`, which Mod_1 do you mean? it's
arguably bad design to mean T_S::Mod_1 (so confusing!) but that's what you
would get if anchor modules included their parent anchor modules. i bet it's
crystal clear now, eh!?

if you want constants to be "inherited down" from one anchor module to
another, the place to do that is e.g. in a module called CONSTANTS that
resides in your anchor module. you would then include that CONSTANTS module in
your I_M or your M_M as appropriate. in flux!  this way it is a) opt-in
whether which modules at a particular node (file) are getting which constants
in their chain and b) for a given product which (er) constants should *be* in
CONSTANTS in the first place.

(now, experimentally, we are doing the above)
