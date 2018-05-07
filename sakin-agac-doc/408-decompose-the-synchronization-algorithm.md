# markdown table-targeted synchronization

## document objective

this document serves dual purposes, one more general and one more specific:

generally, we decompose our [#407] high-level synchronization algorithm
into code-level modules ("magnetics", usually) that we write one by one.

more specifically, begin to tilt the work towards our target use case:
markdown-table-targeted synchronization.




## overview: decompose the synchronization algorithm

as an overview, we decompose the synchronization algorithm in a regression
friendly order. (we may use these points as checklist to correspond to test
files we write.)

1. get the synchronizer to work with a list of names over an exhaustive
   set of cases. this could require as many as three format adapters:
   1. a base class thing for a format adapter itself
   1. in-memory real object (dictionary) stream
   1. json-esque stream
   1. a made up format adapter for a list of names

1. item-level synchronization over an exhaustive set of cases. (come up
   with a format adapter that is totally made up). (requirements for a
   format adapter are many.)

1. magnet: semi-editable DOM-like rows

1. magnet: traverse all lines of the document, but parsed

1. collection-level synchronization as document over a variety of cases
   (that only outputs the new document as a stream of lines! use generator!)

1. a whole diff thing yikes.

1. format adapter for our target use case. note this will have to accomodate
   the crazy tagging stuff, but if we treat that as whitespace it might be
   trivial. (will still involve parsing hacks).




## freeform discussion: xx xx xx

what we're working up to is _modules_ (in the purest sense)
that take as input "resource strings" (or something), CHA CHA

LET'S THINK ABOUT CAPABILITIES:

BUT FIRST:

synchronization

  - a collection of new items (let's call it the "far" collection)
  - a collection of original items (let's call it the "near" collection)

we're gonna just talk about things knowing in advance what we're gonna
need to do without coming from how to science

so let's look at our COARSE ALGORITHM and try to think of its
requirements in terms of what it says about the CAPABILITIES we
might require of the collections.

first, we'll do this of the FAR COLLECTION:

  - ORDERED: we expect the items in the far collection etc

  - NATURAL KEY: each item must be able to produce one

  - (as a detail, any natural key that is not unique in that collection: fail)

  - NAME-VALUE PAIRS: each item, we must be able to model it as such
    an ordered collection (with any name occuring no more than once)

as far as we know, that's it for the far side.

but note that things get more interesting with the NEAR COLLECTION:

  - HEAD LINES and TAIL LINES: (boring but essential)

  - (we are currently side-stepping the issue of multiple tables in one
    document.)

  - SCHEMA-ROW: this establishes the ALLOWABLE SET

  - AT LEAST ONE HEURISTIC TEMPLATABLE ROW

x XX xx XX xx



## (document-meta)

  - #pending-rename: NNN-markdown-table-targeted-synchronization.md
  - #born.
