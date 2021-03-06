# unified language :[#018]

## content (rougly in development order)

  • block: the topmost meta-kind of structure under document.
    kind is `static` or `comment`.

  • run: a `comment` block can be broken down into ths "sub-blocks":
    a "discussion run" or a "code run".

  • item: for "forwards" output (normal use), an item is an artifact
    of tests. kind is `example` or ([#024]). code runs (bolstered
    by discussion runs) make items.

  • node: an experimenal branch-like grouping of items. see [#024].

  • "stem paraphernalia models" (see paraphernalia).
    "stem paraphernalia" is paraphernalia likely to be found in most test
    suite solutions. they are phenomena like "examples", "tests" (see), or
    "setup" (methods). more at [#025], a dedicated document on this.
    contrast with "particular paraphernalia models".

  • "paraphernalia" is our umbrella term for the terms-of-art and jargon
    used to describe the "things" of tests.
    kind is `stem` or `particular` (see both).
    (see "stem paraphernalia model")

  • "particular paraphernalia models" this is for when we want to model
    a phenomenon in a particular test suite solution that has
    no counterpart in the "common" collection. more at [#026].

  • "test" (as a paraphernalia component) is a term we would like to
    avoid. (explanation at [#025]).

  - "identifyings": identifiers used to identify components in
    particular contexts - see [#038]

  • "LTS" - this is a loanword from [sa] - "line termination sequence".

  - "magic" - our general name for the patterns that [dt] recognizes
    in input data that it can translate into output data.
