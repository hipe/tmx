---
title: known issues discussion
date: 2020-08-10T21:35:03-04:00
---

This section is for discussions (around issues) of lower-level and
architecture-related concerns of TMX notebook.



# :[#882.K]: Known holes in our data integrity checks

The known holes are concerned with preventing cycles. We discuss the two
types of cycles we want to avoid.


## Breaking "horizontal" linked lists by introducing cycles

For one thing, we don't want our "horizontal" linked lists to ever become
rings. There should always be a leftmost endpoint and a rightmost endpoint
(somewhere) in every linked list and as such a node must never be added to
the list if that node is already in the list somewhere.


## Breaking trees by introducing cycles

The same principle applies to our parent-child relationship. Consider adding
a would-be child to the children of a would-be parent:

Let the would-be parent's "ancestry" be the child-to-parent chain that
continues upward from any node until some root node is found (that is, a node
with no parent). (A node's "ancestry" includes the node itself.)

Consider that the would-be child in fact expresses a "tree" of the child,
all of the child's children, each of their children and so on.

So here's the provision: for any such would-be child that would be added
to a would-be parent, it must be the case no node in the tree expressed by
the child  exists anywhere in the parent's ancestry.

To do so would break the integrity of the tree, for it would no longer be
a tree: if a node from a node's ancestry also exists in its progency, then
there is no longer a root node; in effect you would search "upwards" forever
and never find it. (More precisely, there is no longer an "upwards").


## Implementation concerns

To do this "correctly" would seem to require that we lock the entire
collection while we edit any linked list edits.


## Ideas for workarounds

We can begin to imagine an improved "verify" command that traverses the
entire collection..


# (document-meta)

  - #born
