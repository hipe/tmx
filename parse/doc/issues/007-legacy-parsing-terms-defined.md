# parsing terms defined - a quest for meaning :[#007]

as with everything, these terms are placeholders for if we ever discover better
terms.

there are two separate but related concerns when trying to parse a surface
symbol from an input: 1) is what we call `matching`, and two is what we call
`scanning`.

whether a given input state matched against a given formal symbol, we call
that `matching`. it can be represented with a boolean. it is just a simple
yes or no for whether the input matched against the formal symbol.

`scanning`, on the other hand (and we don't really like the term so watch for
it to change), refers to both having _matched_ against the input *and*
representing it as / converting it into something more useful. the purest
example is the `scanf()` function of C - if it can, it matches e.g an integer
from the input buffer and results in the data having effectively changed
into a different form (from a string to an integer).

depending on what we are doing, we may opt for simple `matching` instead
of the more complex `scanning`. the only way in which scanning is more complex
than matching that concerns us is in terms of the output signature for the
parsing functions of the sub-nodes of your grammar: if we are only doing
simple matching, we need only look at the true-ish ness of your result,
if we are scanning, however, the result signature (in the abstract, at least)
is no longer `monadic` but `diadic` (Martin, [#sl-129]):

that is, there are possibly two pieces of information we need to get back
from the function: one is whether or not it matched, and two is what is the
result representation look like. (indeed even `scanf` itself employs both
an output argument and a returned result - one to write the the "deep form"
to, and one to tell you how many bytes were read.)

(this furthermore assumes that the result representation is or should be
`monadic` itself, something we will get in to below.)

the astute programmer will think, "well, that's true IFF your parse structures
can contain meaningful nils." this is what we thought too, which is why
we are writing this document:

in cases where your "deep forms" of all of your semantic structures are each
never possibly nil, yes it is convenient to combine both the act of mathcing
and the act of scanning into one function with one monadic result. if the
result is nil, it means it failed to match. otherwise, the parse matched, and
the result structure is the result of the call.

this sounds great, so why don't we do it all the time, you ask? the flip side
of this is that it takes more work to enusre we don't "accidentally" result
in false positives or negatives:

  -> x { /foo/ =~ x  }  # your successful result structure would be an integer
  -> _ { :yes == :no }  # this will always succeed: false is not nil
  -> x { x.zero?     }  # result is false or a Fixnum, again always success.

so as it works out, we have to draw a thick line between whether we are just
matching or also scanning.

the above is actually just one facet of a broader dialog..


## the broader dialog - how do we communicate with the system?

all of the facets in this doc-node can be summarized in the following
questions:


  n.) how may we interact with the input? how is it represented to us?
  n.) how may we interact with the result structure, e.g what behavior is
      available to us with which to represent the semantic result of the parse?
  n.) what are the operations available to us to represent changes in our
      state as it pertains to the broader parser state? this includes things
      like whether the parse succeeded with this input, but also things like
      whether we as a syntactic node, are exhausted.

more..
