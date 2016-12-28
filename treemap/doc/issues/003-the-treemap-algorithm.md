# the treemap algorithm (supplemental notes) :[#003]

## document intro and scope

this is in supplement to the algorithm described in comments in the
counterpart asset (code) node. we keep the main algo there for better
"flow" but put nitty gritty notes here.




## why didn't we reuse some existing thing? :#note-1

reasons we don't use an existing algorithm or code from elsewhere
are several.

  - first of all, we did try. (and boy did we ever. supporting a "strange"
    external platfrom like 'R' led us to create a non-trivial plugin
    framework that led to several wild tangents of its own.) ancient in
    the project's (versioned) history as a proof of concept, we were
    generating a pdf of some dummy data using 'R'. we used 'R' because it
    was the most usable example of a treemap visualization at the time
    (4.5 years prior to this writing).

so in summary:

  - configurability - our "portrait/landscape threshold" is not a thing
    in other algoriths.

  - comprehension - we wanted to solve for the problem ourself so we
    have a deeper understanding of it

  - our requirements - the examples we found "out there" did not seem to
    exhibit the behavior of our model case. they did not recurse into a
    tree structure.

  - platform - being able to have the lib implemented for a target platform
    has obivous advantages..




## normal rectangle units :#note-2, :[#here.1]

assume we are given a rectangle. this rectangle can be of any
dimensions; however internally we refer to sizes of rectangles
in "normal rectangle units", which we convert to at the beginning
of the algorithm and maybe convert back from at the end.

(we might discard this choice to use our own internal "normal"
units, we aren't sure yet. it should not break the algorithm to
use arbitrary world units instead, so assume it is not intrinsic
to the algorithm.) (EDIT: we are probably sticking with these
normal units now that external systems are coming to rely on this.)

the unit is an arbitrary internal reference unit with 1.0 always
used to represent the width of the initial given rectangle. whether
the incoming rectangle is 100 feet wide or once inch wide, to us both
of these rects have a width in "rectangle units" of 1.0.

if the rectangle is twice as tall as it is wide, then its height in
"rectangle units" is 2.0; if its width is half its height, then its
height is 0.5 rectangle units; and so on.

as we subdivide the rectangle into smaller and smaller rectangles,
these numbers get progressively smaller. (so the width of these
progressively smaller rectangles will never meet or exceed 1.0).

we use `Rational` numbers for these values so that (as far as we
understand) there is never any loss of precision; but do note that
as the mesh gets more complex, the storage costs of these numbers
gets progressively higher in a manner that is not arithmetic (again
as far as we understand).




## portrait vs landscape classification :[#here.2] :#note-3

in general it's very simple: a rectangle that is wider than it is tall is
"landscape", otherwise it's portrait. note this classifies the square as
portrait too.

but under the surface it's more intersting: we make this boundary between
"portrait" and "landscape" configurable. more inline under this tag.




## possible optimizations #note-4

for a current rectangle that is for example 3 or more times wide (or high)
than it is high (or wide),

    +--------------------------+
    |                          |
    |                          |
    +--------------------------+

*and* you have (in this case) 3 or more child nodes in the branch node,
it may be more efficient to run the divvy algorithm once into three
buckets, rather than going always by 2. (we intend, however, that the
same result mesh is reached in either case.)

but this is also a function of the "portrait-landscape-threshold" and so
it complicates the algorithm even more. so we're holding off on this for
now until we get good coverage for the simpler algorithm.



## :#note-5

for now we go thru the divvyer even when the user data branch node has
only one child node..
