# "instance table"

the below table relates paths traversed in the digraph at figure-1 with
tests that traverse those paths.

  • the "digraph path" is a sequence of letters, each letter indicating
    an "edge" in the digraph of figure-1.

  • the "test hashtag" is used to tag perhaps multiple test cases that
    should traverse this path.

  • the "num" column should not be trusted as being accurate. in a
    better world it would be generated.

this is not "comprehensive" in any sense (because in part the syntax
supports an infinite number of expressions). but rather, it is just a
rough guide to help us tie our "on paper" syntax with what we have
so far tested and what remains to be tested.


## the table

|"hashtag"  |num| path in graph | description
|test-01     |2x| a             |the empty request
|test-02     |3x| b cd          |unrecognized token from the top
|test-03     |3x| bce f         |operation where args don't parse
|test-04     |1x| bce g h       |op where args parse but there's more after
|test-05     |4x| bce g j       |op where args parse and op can run
|test-06     |1x| b km          |read primitive when it wasn't set
|test-07     |3x| "             |read primitive when it was set
|test-08     |2x| "             |read compound when it wasn't set
|test-09     |1x| "             |read compound when it was set
|
|test-10     |3x| bknpr         |write primitive with invalid value
|test-11     |6x| bknpsa        |write primitive with valid value
|
|test-12     |1x| bkn ps bkm    |write primi |OK) then read prim ("eew")
|test-13     |1x| bkn ps bknpr  |write primi |OK) then write primi fail
|
|test-15     |1x| bknps bknps bce gj |write 2 primis then run an op
|
|test-50-02  |1x| bknq cd       |under frame unrecognized token
|test-50-05  |2x|               |under frame (..)
|test-50-08  |1x| bknq km       |under frame (..)
|test-50-11  |1x| bknq knpsa    |under frame (..)

note that the `num` for the first (longer) section of tests may also
be counting those instances of those patterns in the second section
of tests. (the taggings in-situ should make this clear.)
