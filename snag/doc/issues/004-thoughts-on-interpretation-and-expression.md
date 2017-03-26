# thoughts on interpretation and expression :[#004] --
  ( towards a unified interface for many operations on component structures )

## the objective is..

.. a universal inteface for most operations over models over expression
adapters.




## introduction

the Big Things we have on the table so far are:

  • the input/output dichotomy to be presented below
  - [#fi-004.5] `normalize_qualified_knownness` is the universal way for n11n
  • `express_into_under` is the univeral way for expression
  • the nascent "expression adapters" puts modality first
  • all of the above under "composition" to be presented below




## the IO dichotomy

there will be operations that can be classified as being either:

  • an operation that transforms "input" into a business object -OR-
  • an operation that transfroms a business object into "output"

for now, we will see the plural cases (not just object but object*s*) as
respective sub-classifications of these.

in practice these two categories make up a pretty wide umbrella. one of
them can be reasonably said to contain all of the [#ba-041] built in
common UAO's for entities:

  • [#br-030] create
  • [#br-031] retrive
  • [#br-032] stream
  • [#br-033] update
  • [#br-034] delete

  • under the former: create, retrieve, ( sort of: update, delete )
  • under the latter: stream

this is a bit of an excercise in arbitrarity and semantics: of those
actions that can be classified under the "input" category, they could be
altered trivially to result in the objects they touch; making every UAO
in this list have a near variant that fits into the "output" category.




## integrating the I/O dichotomy

  • `interpetation` is the counterpart word we will use for `expression`.
    ( "expression" is to "output" as "iterpretation" is to "input" )

  • `express_into_under` is established and sufficient for our objective

  • `interpret_out_of_under` would perhaps make an adequate counterpart.

...
