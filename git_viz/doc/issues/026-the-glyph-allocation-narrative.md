# the glyph allocation narrative :[#026]

## pre-introduction

this algorithm has since been generalized out of [gv] but for now the
below description *and code* remains extant in this sidesystem, as well
as being algorithmically duplicated (to some if not the full extent) in
[#ba-054].




## introduction

we take pains to do this in a well-documented, non-obfuscated way because
A) we suspect that the spirit of this is a broadly applicable algorithm
and B) we took a first stab at this as a messy one-off and it proved to
be so brittle as to be useless.

it's probably worth noting that the final form this algorithm took was
wayy simpler than the intermediate form it was taking; which explains
why this rewrite sees an explosion of documentation if not code.




## purpose

this is probably some well known statistical operation: take a series
of positive, nonzero integers (bag not set), and let's just say they are
sorted. the goal of this algorithm is to classify each member of this
series into one of N groups, such that the range the series covers
from smallest to biggest is broken up into N equally sized steps..

this is a bit like a box and whisker plot but simpler: the points where
the "ideal jumps" happen are not determined by the distribution of the
members; rather they are determined by the smallest and largest member
only.




## example

let's say that people in a room are the following heights:

  5'2", 5'10", 5'11", 6'4"

if we want to break this series up into contiguous categories of "short",
"medium", "tall"; the subject algorithm achieves this with absolutely no
consideration for the distribution of datapoints except the lowest and
highest value:

  1. between the lowest (5'2") and the highest (6'4") covers a "distance"
     of 14 inches (but note that in a world where everybody is a discrete
     number of inches, there are 16 possible height values in this range).

  2. divide that distance by the number of categories you want:
     14 / 3 = ~ 4.6 inches per category.

  3. use this rational number to make your categories:

     short:  5'2" -  ~ 5'6.6
     medium: ~5'6.6" - ~5'11"
     tall: 5'11" - ~6'3.6"

     these ranges exclude the value of each "end" component itself.

     note that we lost some distance due to a rounding error - we want
     that last term to a) include its end component and b) be 6'4", not
     ~ 6'3.6". in the code we will address issues like these.




## the pseudocode

  • determine the "expanse": determine the smallest value and largest
    value that any member ever is. the expanse is this distance plus
    one: if the smallest is 7 and largest is 7, the expanse is 1.

  • divide the expanse by the number of "categories", producing a float.
    (here, the categories are for e.g "small", "medium", "large" etc.)

  • since all the values are integers, we will produce a series of
    inclusive ranges, each contiguous with the next and non-overlapping,
    using the above float (somehow).

  • we put this list of ranges into a frontiered, hacked out, custom
    B-tree, so that incoming values can find their category this way.

  • when there are more categories than there is "expanse" (of values),
    since the values are integers, there is no way that all categories
    can be reached in such cases. we hack through this case.
_
