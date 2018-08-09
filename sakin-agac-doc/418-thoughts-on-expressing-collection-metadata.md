# thoughts on expressing collection metadata

## background/intro

this area of smell occurred to us when we transitioned from the
"synchronization" phase to the "tag lyfe" phase. it's the classic set-up
to justify dependency injection.

consider: synchronization cares about "natural key field name" but
"filter by" does not; and "filter by" cares about "tag lyfe field names"
but synchronization does not.




## <a name=2></a>whether to be jack of all trades

for example in the case of markdown tables, our solution for the problem of
needing the "tag lyfe field names" takes on two facets:

  - it is done "eagerly"
  - it is done in a "heuristic templating" style

our answer to the smells this introduced was the idea of "intention",
something that is not yet very formal.

basically, "intention" tries to munge "filter by" and "sync" with mostly
the same code, but gives you better, more directed (and more early warning)
error reporting geared towards your .. intention.




## <a name=3></a>heuristic templating

this relates to #open [#410.S] which (discussed there) pertains to a
particular application of this theory that has yielded mis-behaviors.

but the "theory" of heruistic templating is that we look at the existing
formatting of the document to determine how we format new expression.




## <a name=D></a>example row synthesis

uh..
  - how many cels (characters) wide the cel is




## <a name=E></a>name change

um..
  - one thrust is to push the class up and rename it from "sync parameters"
    to "collection metadata". but this brings up the new smell of the
    dependency injection thrust introduced at the intro

what we would like is that "capabilities" "register" somehow, and that all
registered capabilities expose the property names they recognize for
collection metadata. (this indexing of capabilities would be done lazily,
a max of once per runtime.)

we would end up with such an index:

  - field names: (\*)
  - natural key field name: (sync)
  - tag lyfe field names: (filter by)
  - [ many other sync specific ]

but this is seen as overwrought for now.




## (document-meta)

  - #born.
