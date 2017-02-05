# the infer table utlity

(16:53)

the desire for this whacky little utility was what led us
to unify the table libraries. now that that is complete:




## objective & scope

each line of a text stream (hopefully not too large) presumably read
from stdin will attempt to be parsed using a hand-written scanner
implementing an unsurprising grammar for generic "records".
(think `awk` but without being able to configure record separators.)

on a per-line (record) basis, we attempt to convert each of these
"field" values (as strings) to their simple platform `type`. probably
we will have builtin support for only strings, ints, floats, and
booleans. (think JSON.)

  - support for parsing numbers only in the most unsurprising,
    simple way: [ negative sign ] digits [ decimal, digits ]

  - something like special treatement of `yes`,`no`, `true`,
    `false` (without quotes) as booleans.

each of these "records" then acts as a "tuple" which we analyze
as a "page" of table data using [ze].  finally the fun part:




## table design inference :[#here.A]

with our "page survey" of all the data, we *infer* a table design
with some algortim something like this:

  - for each field in the survey,

    - if the field does not contain numerics,
      try to express this column however it would be expressed
      "normally" by [ze] tables.

    - otherwise (and it contains any numerics), we will use some
      constant threshold (say 0.618): if that portion of all cels
      in this column are numerics, then "yes", otherwise "no".

      "yes" what? yes we "add a max share meter" (below).

      whether "yes" or "no", we express the whole column normally
      as with above.

      (preserve this "yes"/"no" for other summary calculations to
       be discussed below.)

      this threshold term has a dedicated section [#here.B] here.


  - "how to add a max share meter"

    - it would be great if this almost fully "just worked". in the
      cases where multiple such meters would be generated, we have
      the option of assigning them relative widths to each other
      (this left one is half as wide as this right one, etc) but we
      have no basis by which to infer such weights here.


  - finally, one thing we didn't discuss above is that we would have
    to add field observers to each "categorized as numeric" field above.

    we could hand-write a custom observer that not only tallies a
    a max (for max-share, used in generating the max-share meter),
    but also a total.

    then, we could have two or three etc summary rows:
      - min/max
      - total


### this one threshold term :[#here.B]

this value is (vaguely) the inverse of the golden ratio. for now
we just want somewhere between 0.5 and 1.0 (exclusive/inclusive).

what this threshold for is this: if under any given column you take
that proportion of cels that are "numeric", whether or not that
proporion meets or exceeds this threshold determines whether or not
the column is categoried as "numeric".

(if it's numeric we add an additional column for quantitative
visualization (e.g a max-share meter).)

for example:

    Column A    Column B
         foo         1.3
           7         bar
         baz           2

of the three cels under column A, one of them its numeric, so its
proportion is 0.333[..]. column B has two cels out of three that
are numeric so its proportion is 0.666[..]. 0.666[..] exceeds
our threshold but 0.333[..] does not, so column B is classifed
as numeric but column A is not.




## performer breakdown

(this section is to aid in implementation.)

  - mixed tuple stream via line stream
    - tuple via line and parser

  - page survey via mixed tuple stream

  - table design via page survey and inference

  - flush:
    line stream via mixed tuple stream and table design




## imagined crazy yo-yo sequence:

all of the below will be mocking (or actually doing)
a "user story" that is a minimal super-case.

  -8. mock UI with a failure case (how?) and success
      this makes the executable binary and some
      CLI client file. this produces a test file.

  -7. brute force a table design and a page survey
      and get it to integrate with the above case.

  -6. try to produce the above page design thru
      a page survey. (this is the central thing.)
      i.e use the threshold and the statistics, etc.
      this makes
      "table design via page survey and inference"
      this produces a test file

  -5. get the page survey from plain old tuples.

  -4. secondmost big money shot: mixed tuples from
      strings. this makes:
      "tuple via line and parser"
      (in "tuple stream via line stream")
      the produces a test file

  -3. get the page survey from lines

  -2. get the design from the real page survey

  -1. real end-to-end case
