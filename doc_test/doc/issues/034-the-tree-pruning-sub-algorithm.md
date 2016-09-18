# refinement two: enter the trees

(the higher-level algorithm that this is a part of is introduced in [#017].)

we want synchronization to behave in a way that is unsurprising and
predictable under typical use (A) and (B) for those cases where a node
still has the same name but its surrounding document structure has changed
(on the source side, on the destination side, even both), we still want
these two nodes (one on the "left" and one on the "right") to
"find each other" and sync (i.e write from left to right).

towards both of these design factors, we do *not* want to rely *solely*
(if at all) on a simple "recrusive tree merging algorithm". in other words:

    asset file              test file before
       |                       |
       ├ A                     ├ C
       └ B                     └ E
         ├ C                     ├ A
         └ D                     └ D

if we were to apply our [#033] "fine and dandy" algorithm recursively on
each branch node of our source tree to a "corresponding" branch node of
the destination tree (such that each branch node has its own local
namespace), we produce this undesired result:

                             test file after
                                |
                                ├ A
                                ├ B
                                | ├ C
                                | └ D
                                ├ C
                                └ E
                                  ├ A
                                  └ D

that is, if you're looking only at the root branch node of the two sides,
then there's "A" and "B" on the left, and "C" and "E" on the right. etc.
after the merge, these four nodes are indeed at the new root node, but this
is not what we intended.

after this hypothetical sync, all nodes are represented [ABCDE], but
some nodes were duplicated. (in fact, every node that existed on both
side got duplicated because of our intentionally illustrative set-up.)
this duplication violates the spirit of rule (3) in our [#033]
"fine and dandy" algorithm, which holds that already existing items
(by name) will get overwritten (not added again).

let's see what happens if we expand the scope over which we apply rule (3)
so that it says what we mean - that is, there would be one namespace per
document (not per tree branch).

(sidebar: a corollary constraint of such a design is that within any given
file you can't use the same descriptive string more than once. although
there are some structure-patterns of test file which we may occasionally use
that exhibit this trait, A) we don't use them that often and B) we think
that the gains generally outweigh this cost, considering how trivial it is
to make description strings dissimilar to one another.)

if we follow the more broad application of rule (3), then what happens to
node "B" is something of a conundrum: since all the item nodes from the
source already exist in the destination, then:

  - do we "sync" "B" over but as an empty branch node? (eew no - why?)

  - we do not replace "E" (the name) with "B", because for one thing it would
    be hard to define the precise conditions under which we would infer
    that it is OK to change the name of a branch node from one value to
    another; and for another thing it comes close to violating rule (6),
    which is that all item nodes (in terms of name) must persist throughout
    the synchronization. (although we're talking about a branch and not item
    node, we take it to apply here as well.)

so what do we do? we do nothing! in such cases, "B" (the name) does *not*
get synced. note this is *not* a violation of rule (1), because that rule
applies to *item* node, and this is a *branch* node. tentatively we'll
call this :#rule-7. the next section is a proposal for how we can implement
such a strategy.




## let's try the "diminishing tree" algorithm:

in order to explore the sub-algorithm refinement we are about to propose,
we'll start with a scenario that is the same as the above scenario, plus
there's now a new node (node "F") in the source document:

    asset file              test file before
       |                       |
       ├ A                     ├ C
       └ B                     └ E
         ├ C                     ├ A
         ├ D                     └ D
         └ F

first, let's imagine you made a deep-dup (deep copy) of the source document
(or some kind of schematic but simpler representation of it) for the purposes
of the following. now:

in an application of rule (3), traverse over every *item* node in the source
document (incidentally you can do this in any order, but let's imagine it's
a depth-first traveral) and if that item node (by name) exists in the
destination document (anywhere), *remove* this item from this mutable
notation structure (and maybe add it to a memo list, we're not sure).

as you encounter them (check this when you're about to leave a branch node),
empty branch nodes can also be removed from the "note tree", as an
application of our new :#rule-7. (what "empty" means may be refined in a
future document: [#036]).

     notes                  test file before
       |                       |
       └ B                     ├ C
         └ F                   └ E
                                 ├ A
                                 └ D

that is, because A, C and D already exist in the destination document,
we removed them from the note tree (for reasons we haven't explained yet).

now the "note tree" is what we'll call a "pruned tree" - it consists of
only item nodes that don't exist in the target document, or branch nodes
that hold those item nodes (and maybe some more pieces that we will refine
in the next section).

now (remembering this is only conceptual and not quite what we're actually
going to do), we can take this "pruned tree" and do this:

at each branch node recursively, apply the "fine and dandy" synchronization
from this node in the source document to a corresponding branch node in the
target document:

  - note we will never need rule (3), which applies only to those nodes
    that exist in the left but not in the right. we removed those and
    memo'ed them above.

  - for each branch node that is not the root branch node, we will need
    to "touch" (i.e create if necessary) a branch node in the destination
    document.

one final catch for this sub-algorithm: let's try applying the same
universal namespace lookup for these branch nodes that we use for the item
nodes. as such:

  - when indexing both the source and destination documents, duplicate
    names (within one document) should raise runtime (or other fatal) errors.

  - we will then have to check that the "shape" of the nodes are the
    same - an attempt to sync a "same name" case when the left side is
    branch and right side is item (or vice versa) must raise some kind
    of fatal (possibly soft) error.

this also means that "structural" elements from the pruned tree don't get
transferred over to the destination document IFF an existing branch node
already exists structurally elsewhere in the destination document.

precisely how to do this is super fun. here's a super-contrived case:

    asset file                       test file before
         ├ wazoozle test                 └ chamoonga context
         └ bazoonga context                └ zazoozle test
           └ chamoonga context
             └ fazoonga context
               └ gargoyle test

note the only commonality across the two sides is a branch node called
"chamoonga". there are two tests on the left side that need to end up on the
right. of the two, the case of what to do with the "wazoozle" test is easy -
it is under the root node in the source tree so put it under the root node
in the destination tree (probably by applying the [#033] "fine and dandy"
algorithm across the two associated branch nodes).

but as for the other test that needs transferring (the "gargoyle" test),
what to do here is crazier. note that on the left side it is under
"bazoonga"/"chamoonga"/"fazoonga". over on the right side, of those three
branch nodes, one (and only one) of them exists by name ("chamoonga").

what we do in such cases hopefully "feels" natural but will be hard to
put in words because we're tired. (EDIT)

in this manner each item node that existed in the source document that
did not exist in the destination document gets written to the destination
document.

we're almost done refining our higher-level algorithm to fit our real
world case, but there's one more stone we have left yet unturned: (EDIT)
