# the const reduce narrative :[#029]

## pseudocode

reduce a stream of zero or more string-ish "token" items (string or symbol)
against a "current item". for robustity and algorithmic parsimony, we'll
say that at any point, the current item could be *any* value, including a
non-module (and including false-ish).

what is given to start is a current item and the stream (array) of zero
or more token items.

while there are more tokens in the stream, for each next token (which
we'll call the "current token"),

  - if the current item is not a module, this is some kind of error.

  - otherwise (and the current item is a module)

    - [ attempt to resolve a value for the const-ish by any means ]

if an ad-hoc error case was not encountered, the final result is either
the "current item" or a tuple pair of the current item plus its correct
const name used to resolve the item value, depending on options.




## document meta
  - all previous content #tombstone

## :#death-to-the-peek-hack (#tombstone)
