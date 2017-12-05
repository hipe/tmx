# the test document

## about this document

### objective & scope

this is an experimental format that is something like a pseudocode
document but for a model.



### prerequisites & foundation

this builds on [#017] our "essential operation" [about syncing] pseudocode.




## requirements (overview)

  ✓ (step -N: ersatz parser)

  ✓ requirement -4: (step -N)

 	  ✓ (anti-requirement): we will allow ourselves to fail with some
      documents while [#002] this is a hack.

    ✓ "lossless" - needs to be able to output every byte that went into it.

  • requirement -3: (step -N)

    • positional & relative access to nodes
      ✓  be able to get the first node from the document
        (probably we need to model document nodes like module and `describe`)

    • random acccess to nodes
      • be able to retrieve a context node by name
      ✓ be able to retrieve an example node by name

    • start to think about how to access unassertive nodes..

  ✓ requirement -2: (mutability 1/2): nodes can be added (..)

  ✓ requirement -1: (mutability 2/2): item body lines that can be replaced

    ✓ after having retrieved an item node, be able to replace all of
      its body lines with new lines. (step -N)




## requirement -4: parse most such documents, do so losslessly

(#coverpoint3.4)




## requirement -3: random access to nodes

since nodes can never be removed, maybe we can index these. but what if
we change our minds?

we don't know what we're going to do about unassertive nodes (tho they
*can* be indexed by lvalue name, can't they?)

(#coverpoint3.3)




## requirement -2: nodes can be added

we need the ability to add a node before another given node (with such
an interface).

we likewise need the ability to add a node *after* another given node.

(#coverpoint3.2)




## requirement -1: replace item lines

(#coverpoint3.1)
