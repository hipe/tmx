# the word wrap narrative :[#033]

## notes from the aspect ratio node

### introduction to this node

given an arbitrary target aspect ratio and an arbitrary body
of text, try to "delineate" the text into the target ratio
with some sort of "best fit" algorithm that takes into
account an avoidance of "orphanic-ness".

note this stands in contrast to most word wrap algorithms
that simply wrap the words within a given fixed width,
creating a delineation that grows downward with more content:

this is a specialy form of word-wrapping whose delineation
grows growing downward and outward at roughly the same rate
as contact is added.

as well we added correct behavior for breaking up words with
hyphens.



### #note-A

given the target aspect ratio and given the input content's
total number of 2-D "cels" (characters, points, picas;
whichever), we can make a *rough* guess at the result width
and height with a simple algebraic formula (solve for N):

    the actual output area (rougly) =
      width aspect ratio component * N *
        height aspect ratio component * N

    area = width component * height component * N^2

    N^2 * width component * height component = area

    N^2 = area / width component / height component

    N = √ ( area / width component / height component )

the reason this guess will only ever be "rough" is: a) there
is the simple dynamic where each surface piece (space or non-
space) has a potential length of zero to infinity, making
the actual fit into a target width be "impossible" to predict
without looking at each piece for a given target width and b)
there the dynamic where at each line break we don't use (but
rather lose) the space surface pieces (always separators) if
it's not the breakable zero-width location after a hyphen.

we have not proven but assume that the emergent behavior as
a product of the dynamics (a) and (b) together makes it
impossible to determine our "best fit" width and height with
simple algebra alone.

we presume there are other formulaic dynamics to this machine
with varying degrees of usefulness and accuracy:

A) there is probably a tendency as a corollary of (a) whereby
as the target aspect ratio gets taller (i.e thinner) the more
more space surface pieces will generally be omitted (because
space pieces are discarded if they fall immediately before or
after a line break). this tendency (if it exists) would count
against our calculation for "area" above as some function of
the ratio between space and non-space pieces in the input
stream. however:

B) for any given delineation of any given input stream, every
line that is not a perfect fit for the target width will
"waste space" at its end and add verticality to the actual
output rectangle, adding actual area beyond the area guess
we came up with in the above formula.

although we have not proven this to ourselves rigorously, for
now we assume that to turn the above two theoretical dynamics
into code would muddy it at a cost greater than their
potential value.
