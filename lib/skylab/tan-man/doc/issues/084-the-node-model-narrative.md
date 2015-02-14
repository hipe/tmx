# the node model narrative :[#084]

## :#lexical-esque-node-insertion

this algorithm is a specialized form of :+[#br-011] the lexical-esque
insertion strategy:

When creating new nodes this is how we determine where they go:
(this is likely not implemented fully as you read this)

  + if you find any existing node statements,
    + if you encounter any first one that is lexically greater than you,
      you should go immediately before it (order).
    + else (all the nodes were lexically less than you), insert yourself
      before the first statement that followed the last node statement
      you ever saw (proximity).

  + else, since you did not see any node statements at all
    + if you saw any edge statements, you should go immediately
      before the first one you saw (taxonomic order).
    + else, since you did not see any edge statements, you should go
      at the very very end after any existing statements at all (idem).

The above, if left to its own devices, will ensure that all node stmts
get added in alphabetical order with respect to themselves, and come
before e.g. all edge stmts.

Aesthetically we like to have `node_stmts` appear before any `edge_stmts`
that refer to them. But functionally it is imperative that stmts
that alter the appearance of other statements come before those stmts
to which they are supposed to pertain.
