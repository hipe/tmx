# discussion of all the meta-property libraries

first, a quick history:

  |  Name                |  Identifier  |  Approx. Start  |
  |  formal attributes   |  [#mh-024]   |  2011-09-11     |
  |  parameter           |  [#hl-089]   |  2012-08-29     |
  |  field               |  [#ba-003]   |  2013-04-11     |
  |  ??                  |  [#ta-081]   |  2013-10-11     |

  • first, there was "formal attributes" [#mh-024]
  • then there was "parameter" [#hl-009]
  • then there was "field" [#ba-003]
  • then, during the "headless earthquake" of late 2013.. (well, read below)


## formal attributes was the first stab at a meta-properties library

it started on 2011-09-11 with a 40 line DSL extension module. it may prove
to be the only one still standing when all this dust clears.


## [hl] parameters was a successful experiment that failed to improve the above

on 2012-08-29 it first got individual recognition. for some reason we tried
to cram every meta-attribute that would ever be used into one scope, thinking
mistakenly that it would somehow make life easier. it did not. a longterm
goal is to absorb all the good parts of this into the above.


## then came the N-meta experiment with [ba] field

in 2013-04-11 we attempted another experiment: what if saying "meta" was
itself varible? this may or may not be useful, but is sitting there now
in meta-fields.


## frustraded by the diaspora, the solution was to add to it

watch for upcoming "config shell" [#ta-081] that is lightweight, ground-up
rewrite of basically all of the above. among other things, the novelty that
this guy brings is:
  + meta-attributes *and* attributes are both modeled alongside each other
    as properties of a class (accesses by reader methods, and truly memoized)
  + meta-attributes and attribtues are immutable. to change them is
    to re-write them.
  + given the above, inheritance works lazily, leveraging the existing
    inheritance model of ruby instead of the graph deep-copying that
    happened in formal attributes [mh-024]
_
