# the name narrative :[#005]

## the contagious name function :[#.A]

### the reactive tree is a sparse subtree of the constant namespace

in a [#pl-011] reactive tree, each node must be able to know its "full name"
in the context of that tree. it takes work to derive this tree from
the constant namespace because the reactive tree is a *sparse sub-
tree* of the constant namespace tree in several regards:

  • the root of the reactive tree is at an arbitrary depth
    within the platform's runtime constant namespace.

  • the interesting nodes of the tree are interspersed with
    officious "box modules" with names matching particular
    patterns, which must be "hopped over" when deriving names.

([#016] describes "inferred inflection" which informs the above.)




### pros & cons of caching

consider the two sibling nodes 'A::B::C::D1' and 'A::B::C::D2'.
without caching, each must do the work redundantly of de-referencing
'A::B::C'. in our typical application of about 7 nodes at a depth of 3,
to produce an index listing of the reactive nodes (from the toplevel
only), 36 pair structures would be created with only 10 of them unique,
the rest redundant. likewise without caching many redundant const
lookups are made.

the only forseeable cons to this sort of cacheing are deemed moot:

  • the rate at which nodes are added to a reactive tree is slow
    enough that there will never be enough nodes in the cache to
    warrant needing to clear it (unless we ever try to run on a toaster
    or something).

  • this will cause nasty failures if ever the constant values are
    changed for nodes in the reactive tree, but no one should ever
    be doing this anyway. (we see const re-assignment as a mis-feature).




### why infection

once we have built a name function for a particular node, of course we
wouldn't want to build that same name function subsequently. the only
sensical storage location for that name function is in the node itself.

presently reactive nodes may be classes, procs, or (in the case of
branch nodes) plain old modules. actually they may be any object that
quacks correctly; and we have built it so that just a plain old module
quacks correctly as a branch node, and just a plain old proc quacks
correctly as a terminal node.

so note that out of the box (the framework user's box, that is), these
nodes will not necessarily respond to `name_function` themselves (yet).

the child node derives its full name by building it upwards in a linked
list manner to the root node of the reactive tree. the child node's
handle on the parent is *through* its name function; that is, it is the
name function itself that holds the reference to the parent (module),
not the child node.

in order for the above process to work, the parent nodes will need to
respond correctly to `name_function` by the time the child node asks for
it. the way we accomplish this is:

  1. assume we have a leaf node whose name function must be built.
     to build this we must know who the parent node is. to determine
     the parent node we will do string arithmetic on the leaf's fully
     qualified constant name (or ersatz same in the case of a proc
     proxy.) with this alongside the aforementioned cacheing and
     "hopping", we can derive the parent from the constant namespace.

  3. that parent must itself respond to `name_function` by the time we
     are done. so if it does not, we define the method on the parent.

  4. perhaps unnecessarily, we "infect" all the way upwards at this
     point. whether or not this is necessary or helpful is left as a
     question to ponder in some future or alternate timeline.
_
