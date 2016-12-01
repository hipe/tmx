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
booleans.

  - support for parsing numbers only in the most unsurprising,
    simple way: [ negative sign ] digits [ decimal, digits ]

  - something like special treatement of `yes`,`no`, `true`,
    `false` (without quotes) as booleans.

each of these "records" then acts as a "tuple" which we analyze
as a "page" of table data using [ze].  finally the fun part:




## table design inference

with our "page survey" of all the data we *infer* a table design
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
