# the entity narrative :[#001]

## introduction

both because and in spite of the various exploitation that it receives
in the broader universe, the term "entity" is reused here to signify a
concept whose meaning when compared to those from other scopes is in
some ways similar and in others distinct.

in [cu]  (as elsewhere) an entity encapsulates a collection of actual
properties. but let's set aside any preconceptions of what we thinkx
this term "entity" means means and reapproach it anew for [cu]:

the shortest reasonable synopsis of this whole document is:

    a [cu] "entity" is a bag of name-value pairs.

in more detail, in [cu] an "entity" is:

  • an *unorderd* collection of "actual properties". to use another
    term, this collection is a "multiset" or "bag".

(for review "multiset/bag" means an unordered collection where there
constituent items are not necessarily unique with respect to each
other, for some definition of identity.)

that's it. so the question then becomes,




## what is an "actual property"?

in other uses an "actual property" is typically associated with one
"formal property" and one "actual value". in [cu] it is not. in [cu] an
"actual property" constists of:

  • one "property symbol"
  • one "actual value"

that is, in the first-step [cu] "entity", each actual propertiy is not
associated with some notion of a "formal" property. it is essentially
just a name and a value.

so the datamodel so far becomes:

    +--------+     +-----------------+
    | entity |---o | actual property |
    +--------+     +-----------------+
                       |        |
                      /          \
              +----------+    +--------+
              |   name   |    | actual |
              |  symbol  |    | value  |
              +----------+    +--------+




## what is a "property symbol"

to put it simply, the "property symbol" is just a name and nothing
else.

so far, in [cu] a property symbol exists only as a would-be key for a
an imaginary specialized dictionary specific to the stream of entities
in question.

more specifically, the "property symbol" of an actual property of an
entity is necessarily *not* associated with any sort of "formal
property" or other metadata (at this pass).

any next entity may in its bag of actual properties contain any actual
property that uses any property symbol. that is, these entities are not
structured, they are totally polymorphic. each entity from one to the
next may have a totally different "structure" than the one before it.




## what is an actual value?

to keep things simple and consistent, we decree that in [cu], the
entities produced by an entity stream have actual properties each of
which come with *no* type associations. that is, they are some sort of
"raw data". this makes things more interesting further down on the
pipeline as we will discuss in [#004].

because of their universality and human-readability, "strings" are the
universal substrate we chose to represent these data, free of type
association.

we will certainly be able to exploit and query against numeric or other
type-aware data derived from these strings, just note here that a
conversion to numeric data (as necessary) is squarely outside the scope
of this step.

on this same broad topic, note now that we will later see that for some
criteria on some "fields", the actual value is
ignored/meaningless/undefined.

...
