# indexing for fufillment (the "index" node & family) :[#013]

## overview

for the current 3 "bundled modalities" (API, niCLI and iCLI), for
those interface graphs that have interdependent (that is, not fully
autonomous) nodes, those nodes may need to navigate the stack:

  • to determine whether they are available, and
  • (for those nodes that are operations) to assemble their arguments.




## introduction to the problem

[ac]'s "operation" facilities support the [#027] "isolationist" model of
operation where its formal parameters are "bespoke": a bespoke parameter
is one indicated by the formal operation implementation as being recognized
(and maybe even expressed as required/optional), however it is not
associated with any components defined by any nearby ACS.

[ze], however, supports (encourages even) formal operations whose
parameters are associated with component associations or formal
operations in its "stack set" of nodes. we call this the "socialist" model
(because sharing). the isolationist/socialist dichotomy is defined and
explored further in [#027].

for now, for backwards compatibility and *maybe* for the convenience of
it, [ze] supports both "bespoke" and "socialist" parameters. (we flip-
flopped on this choice *twice*.)

as that document's treatment of "socialism" theorizes and
[..]/subnode-01.dot exemplifies, any operation may prerequisite

  • any "atom-esques" and
  • any other operations

that are "visible" in that formal operation's "selection stack".




## statement of the problem (design objectives/requirements)

these are the main challenges of implementing the above:

  • we do not want to cycle. if there is a cycle in the dependency
    graph, then both out of courtesy and towards robustness we want
    to detect the cycle and fail meaningfully rather than recurse
    infinitely.

  • we don't want to cache "too little": caching too little means we
    calculate redundantly the availability of nodes in a graph (e.g
    where A needs B and B needs C and A needs C, we do not want to
    evaluate the availability of C more than once. the exemplar graph
    holds cases like these.)


        A ---------> B
        \           /
         \         /
          +-> C <-+

  • we don't want to cache "too much": in a [#ac-023] fantastical world
    where a root ACS outlives the fulfillment of *one* user-requested
    operation, we don't want all this subject caching to mask the actual
    state of the tree.

  • this general problem (that we refer to as [#027] "parameter sharing")
    is one that supercedes the three "bundled modalities" - whatever
    solution we come up with here must serve each of these modalities
    equally well with nominal integration work for each modality.




## a solution

every of the three implementations of "bundled modalities" will ETC..
