# unified language :[#002]

## objective and structure of this document

as [#sl-157]'s "unified language", this amounts to a prescriptive "glossary".

this document is meant to be a (hopefully comprehensive) overview of the
constituent concepts, but development of each one at full depth belongs
not here but in their respective dedicated documents as necessary.

near the top we introduce concepts that are either more general or more
atomic, and then downwards we present concepts that are generally more
derived from these.




## the concepts

  • (theory-ish:) "cel", "span", "overlap"/"intersection" [#005]

  • "LTS" - "line termination sequence" is our formal name for what we
    casually call a "newline". an LTS can be "\n", "\r\n", "\r" or it can
    be a special zero-width occurrence. (from [#011])

  • "occurrence": a "span" with business relevance: either a match or
    an LTS.

  • "sexp" - S-expression (see elsewhere). used as an intermediate
    structure to express final output.
_
