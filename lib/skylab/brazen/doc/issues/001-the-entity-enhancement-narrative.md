# the entity enhancement narrative :[#001]

## introduction

this document is a high-level overview of the **non-iambic** parts of
the syntax of entity enhancement, as well as the iambic parts as
available at this node.  that is not supposed to make sense yet.


## on variable name idioms endemic to this node

for consistency we use the same instance variable names for the same
kinds of things universally at this node and its children nodes, even
though sometimes it may look weird:

for the sake of readability and at the expense of self-documenting code,
we give these kinds of variables single-word names and document their
meaning here, rather than giving them longer self explanatory names that
while possibly aiding in comprehension on the first reading would
ultimately to the initiated eye fill the screen with noise.


(in addition to the below list we may use [#sl-130] single-letter
variable names when appropriate.)

### the list

• `@reader` (:#reader-vs-writer)

  we use the reader/writer dichotomy because although it may
  be misleading at first, once the meaning has been explained, the
  author feels that these can serve as labels whose meanings are most
  easily remembered compared to other alternatives.

  keep in mind the difference between properties and their values. the
  properties in this library are generally associated with a *class* (
  or module) and their values are generally associated with an instance
  of such a class (sort of). (this is the exact same idea as
   [#mh-024]:#formal-attributes-vs-actual-attributes)

  at the level of abstraction of this library, when we speak of
  "readers" and "writers" we are generally
  not talking about things that read and write property *values*, we are
  talking about the things that read and write the properties themselves.
  so, to use the above terminology we are talking about the formal arguments,
  not the actual ones.

  (there will be exceptions to this but hopefully they will be apparent.)

  so then in this implementation the "reader" and "writer" are both
  modules (and remember a class is a kind of module). the "reader" is
  the module we will use to get a handle on the box that associates
  property names with methods that access those properties, i.e to
  "read" the property (object).

  the "writer" is the module we will use to write new methods to (that
  is, define them) that will access the property objects (in this
  implementation with closures).

  it is not a perfect fit but it is good enough for now.

• `@writer` (see #reader-vs-writer)
