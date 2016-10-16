## numbering scheme

generally, and at the first level:

  - 10s      support models
  - 20s      support magnetics
  - 30s      public models
  - 40s      public magnetics
  - 50s      operations (via API)
  - 60s      CLI
  - 70s      iCLI
  - 80s      w
  - 90s      i


at this first level:

  - X2 (12, 22 etc)   the (dependency) "task" sub-lib
  - x4 (14, 24 etc)   the "eventpoint" sub-lib
  - x6 (16, 26 etc)   the magnetics sub-lib




(the below is kept for #posterity - probably the first time we did such a thing)

## intro

experimentally we are planning for the testspace to be totally flat.
we have five "waypoints" (each waypoint of which will certainly have at
least on testfile).

this number of waypoints is of course only a projection: the number of
waypoints is likely to grow and any waypoint may develop a number of
interceding steps (or sub-waypoints if you like) and so on.

so the objective here is to come up with an initial test numbering
distribution that allows "enough" room for this guy to scale out
to our reasonable projection of number of nodes by distributing our
initially projected requisite number of waypoints "evenly" across a
numberspace whose size we have determined empirically (and as an
estimate). (we might divide the space by 10, a change whose impact would
be trivial on the theory and results presented here.)


## rough algebra

    (EDIT: 3.5 months later, we finally make [#ts-024] the "subdivide" script.)

    five waypoints ("items")

    999 slots (1 thru 999 (not 0, not 1000))

    each item will have its own "buffer span" to its left and one to its
    right. as a corollary each buffer span will be flanked by either
    another buffer span or one of the two boundaries of the numberspace:

         bs item bs bs item bs bs item bs
        |                                |
        |1                              N|

    the above example of three items implies six buffer spans

    number of buffer spans ("B") is simply number of items ("N") times two.

    each item will take up one cel (pixel, "slot").

    the question is what slot number does each item occupy, given the
    item's ordinal number and so on?

      • the slotnumber for the first item is one plus
        the width of the buffer span ("W").

      • the slotnumber for any nonfirst item is one plus W (again) plus
        ( the number of items before it times the width of an item-unit
        ( 2 W + 1 ). )

    so generally we have to solve (once) for W.

    the full width of the itemspace will be taken up by one slot for
    each item plus (the number of items times two times the width of
    each buffer span):

    999 = N + N ( 2 W )

    999 = 5 + 5 ( 2 W )
    994 =     5 ( 2 W )
    994 = 10 W
    99.4 = W

    first test: 100

    second test: 300

    third, fourth, fifth: 500, 700, 900

    oh.
