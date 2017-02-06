# file coverage :[#012]

(this copy is very old; salvaged from very old code)

the central thesis of this whole thing is that we hold a test tree up to a
code tree and make it "line up" and see what the differences are by merging
the two trees while maintaining their differences. the trees start out as
isomorphic with lists of filesystem paths, but to make them "line up" we
have to "squash" the test folder itself (a monadic stem node) out of the
picture, and hold the remaining tree up agains the "hub" node, or parent of
the test tree. it makes more sense if you use the "-tct" option to see the
two trees that go into making the final tree.




## see also
  - [#013] file coverage implementation notes




## (tombstones etc)
  - #tombstone: was ancient code
