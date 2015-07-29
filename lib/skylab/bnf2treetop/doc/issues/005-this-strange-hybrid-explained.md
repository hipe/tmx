# this strange hybrid explained :[#005]

unlike most other subprodcuts, `bnf2tretop` "ships" as a standalone file
yet integrates with the `tmx` supernode *and* has an extensive test suite,
for which it is superficially structured like a conventional subproduct.

the script has a `$PROGRAM_NAME` check at the bottom of the file so that
it can be run either as an executable or be used to load the client
without running it, e.g. for being loaded for use by the test suite.





## brief history

the development of this utility helped drive the [hl] framework, one
that informed heavily whatever we are doing today. however, as the
support libraries like [hl] developed and matured; we intentionally left
this utility as-is with its DIY implementation, for posterity and as an
ongoing experiment.


..

# :#tombstone: lots more (now irrelevant) content
