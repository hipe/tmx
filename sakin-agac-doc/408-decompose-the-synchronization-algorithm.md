# decompose the synchronization algorithm

## overview (regression friendly order)

1. get the synchronizer to work with a list of names over an exhaustive
   set of cases. this could require as many as three format adapters:
   1. a base class thing for a format adapter itself
   1. in-memory real object (dictionary) stream
   1. json-esque stream
   1. a made up format adapter for a list of names

1. item-level synchronization over an exhaustive set of cases. (come up
   with a format adapter that is totally made up). (requirements for a
   format adapter are many.)

1. collection-level synchronization as document over a variety of cases
   (that only outputs the new document as a stream of lines! use generator!)

1. a whole diff thing yikes.

1. format adapter for our target use case. note this will have to accomodate
   the crazy tagging stuff, but if we treat that as whitespace it might be
   trivial. (will still involve parsing hacks).


iterate and come back to here!



## (document-meta)

  - #born.
