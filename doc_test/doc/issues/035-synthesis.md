#synthesis of the #forwards-synchronization-algorithm :[#035]

applying some of the ideas and addressing some of the concern of [#033]
and [#034], here we synthesize something resembling our final
:#forwards-synchronization-algorithm.

some conventions used in this document, quickly:

  - "the right [side]" is shorthand for "the destination document"
    and "the left [side]" is shorthand for "the source document".

a high-level summary of this algorithm is that we:

  1) index the "reference" document (also called the destination document)
     somehow

  2) build a "plan" from all involved (this is the workhorse step)

  3) execute the "plan" to mutate or produce the new destination document.


so, we will index both the destination tree (somehow) and source tree
(somehow), and with both trees the following may be relevant:

  - every node is either a branch node or an item node.

  - when we say to traverse the tree "in the common order", we mean visit
    each node in order (top to bottom; left to right; first to last; however
    you are visualizing it), and when you encounter a branch node, descend
    into it and continue the traversal recursively. (this doesn't seem to be
    "pre-order" or "in-order" or "post-order" because those seem to be for
    binary trees only but we're not sure. it *does* seem to be "depth first".)

  - in practice we consider it bad style to have more than a certain level
    of depth to our test document trees (most test cases are under one
    context, many are under no context, very few are under two or more).
    however for the purposes of this algorithm, we model it such that branch
    nodes may occur arbitrarily deeply, because assuming so makes the
    algorithm simpler at no cost (and is probably a good separation of
    policy from mechanism).

  - item nodes come in three types (conceptually if not actually):

    1) "normal" (an example node, i.e "test" ([#018] don't call it a test))

    2) "shared subject" - these have a branch-locally unique name,
       but their name is certainly *not* universally unique in the scope of
       the whole file. assume their position in the branch node is arbitrary
       and must be preserved (sort of).

    3) a "before all" node - as we see it, there is only ever zero or one
       of these in a branch node. (we're not sure what we'll do when there's
       more than one.) assume that the position of this item in the branch
       node is arbitrary and must be preserved (sort of).

    if we need a meta-category to contain the latter two categories
    (for conceptualizing, modeling and/or documentative description),
    call it "setup node".

so:

  - index the destination tree (somehow):

    - end up with a "box" that is a universal flat index of universal
      names pointing to nodes (somewhow), both branch and item.

  - index the source tree, using the "source tree indexing algorithm"

  - finish by "the finishing algorithm" (below)

here is "the source tree indexing algorithm":

  - this algorithm assumes the existence of the destination tree index.

  - maybe start by making a mutable deep dup of the whole tree (or perhaps
    just make a mutable, structural representation of it). whether we do
    this or mutate the original tree is seen as a low-level implementation
    decision that, while being determined largely by characteristics of
    this algorithm, is in fact a bit outside of its scope.

  - traverse the tree in the common order:

    - check-touch a document-universal hash whose only purpose is
      to ensure that each node name is document-unique. (branches and
      items share the same namespace for this). if not unique, for
      now we fail. (or we could skip this node with a non-fatal error.)

    - if the node is a branch node,

      - as implied by "in the common order", recurse.

      - once you come back from recursing into the branch node, apply
        "the branch semi-post-processing function" on it. for its
        arguments this function needs the *two* involved branch nodes
        (parent and child) and the "document-universal queue". this
        might result in a fail/skip, and might result in removing
        the branch node from its parent branch node.

    - otherwise (and the node is an item node),

      - if it is a setup node, leave it as is for now.

      - otherwise (and it is of "normal" type),

        - see if there is a counterpart node by name on the other side.

        - if one exists,
            see if it is of the same type.
            if so,
              remove it from this branch node and add it to the
              the "clobber queue".
            otherwise
              for now we'll fail or skip

        - (otherwise (and it does not exist anywhere in the destination
          document), leave it where it is in the branch node. we will
          come back to it.)

here's "the branch semi-post-processing function":

  - (the branch node may be empty at this point)

  - see if there is a counterpart node by name on the other side.
    if there is,

      - check to see if the type is the same.

        - if it is not, we fail or skip

        - otherwise, memo this for below.

  - if the branch node is empty, remove this branch node from
    its parent branch node completely (#rule-7).
    (reminder: branch nodes can get emptied because of removals we do
    in this algorithm.)

  - otherwise, if there is a counterpart node on the other side then

    - (recall that it's guarateed to be of the same type at this point)

    - remove this branch node from its parent branch node

    - add this branch node to the "dandy queue".

  - (otherwise leave the branch node where it is)

  - (results of this are as follows:)

       - the child branch could have been moved to the "dandy queue".
       - it could have failed or skiped
       - it could have resulted in removing the child branch from parent.

this is "the finishing algorithm":
after having done all the above, we now have:

  - what we're calling the "clobber queue", of zero or more length,
    each element of which [is or represents] an item node that (by name)
    *does* exist on the right side.

  - what we're calling the "dandy queue", of zero or more length,
    each item of which is a branch node that (by name) *does* exist on the
    right side, is not empty, and whose each child is:

      - if item node
        - if normal do not exist on the right side
        - otherwise (setup node) assume nothing.

      - otherwise (and branch node), does not exist by name on the
        right side and matches the "creation branch" definition
        recursively. (the "creation branch" definition is next)

  - what we're calling the "creation tree", which is a tree of arbitrary
    depth whose each of whose nodes (and we call this the "creation branch"
    definition) is:

    - an item node that
      - if normal does not exist in the destination
      - otherwise (setup node) assume nothing.

    - a branch node that (by name) does not exist in the destination,
      is *not* empty, and matches the "creation branch" definition
      recursively.

whew! so these three structures combined together we can call the
"document synchronization plan".

  - apply both the tree and the queue to the destination document somehow.




## :"code notes"

formulate a plan that when finished consists of these three components:

  - "clobber queue" - example nodes to overwrite

  - "dandy queue" - context nodes that exist on the right (by name)
    composed of one or more nodes that don't yet exist on the right
    (:#note-1)

  - "creation tree" - context nodes and example nodes that do not
    exist on the right.

because our algorithm needs the identifying strings (context nodes,
example nodes) to decide between a create and an update, and because
only the particulars and not the abstracts know their identifying
strings, and because those example nodes that are sibling to shared
constant assignments must be constructed with special processing that
is sensitive to which const assigments are sibling to and physically
above them; we collapse the child nodes of context nodes into a stream
of particulars almost immediately.

there are some constraints that we can exploit on the "left" side that
are not in place on the "right" side:

  - in real life we can write `before :all` blocks immediately under
    the `describe` block; however, through synchronization such
    paraphernalia is only ever expressed as being under a context
    (just because that's the way the syntax is).

  - when (ersatz) parsing a test document, we have to anticipate that
    there is an arbitrarily deep recursion of context nodes inside
    context nodes. however, on the "left side" the maximum depth that
    occurs is fixed: we cannot express contexts inside contexts in our
    asset documents. however however, we may pretend we don't know
    this for algorithmic simplicity.
