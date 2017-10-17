# crazy town pruner :[#011]

## overview

the reason we are writing this now is because we *almost* embarked on
implementing this for the current work. we however thought better of
it and decided to table it, as such an effort takes us far oustide our
current scope.

the above choice was a bargain with the OCD gods: because this idea
tickles our fancy so much, we want to reassure ourselves that we are
not missing an opportunity.

(the above two paragraphs could be removed if we reach implementation.)

coverage tools allow us to determine what code is and isn't executed
durings tests at a level of granularity of (if we like) the line-level.
(see cross-reference: [#025.D])

our parsing facilities, in turn, allow us to represent the code as AST's,
which can know what line of code they correspond to.

the theory behind this project is that we use coverage information in
concert with some kind of "smart" AST's to programmatically *prune* a
codebase of code that is not covered.

(edit the above #open [#047])




## document-meta

  - #born
    (note that the idea precedes this file by probably a few years)
