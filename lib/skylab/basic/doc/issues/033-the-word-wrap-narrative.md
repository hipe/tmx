# the word wrap narrative :[#033]

## essentials

this library will attempt to "[re] delineate" your text given these
fundamental ingredients: you provide a desired width (as in, number
of characters), a "downstream yielder", and some strings. the word
wrapper will try to break your input stream up at the joints between
what look to it like words and write these newly formatted lines to
your "downstream yielder" (with `<<`), such that (ideally) the lines
are as long as they can be without exceeding the width.

  • your downstream yielder could for example be an open IO stream
    (e.g an open filehandle, STDOUT), an array, a string, an
    ::Enumerator::Yielder. use anything that responds to `<<`.

  • you can either `call` word-wrap or create and use a word-wrap
    session. (implementation-wise, the former is a short wrapper
    method around the latter.)

    which to use is probably best determined by the characteristics
    of your string data: use the former (maybe) if you have it all
    in one big string and want the word-wrapping operation to feel
    like a single function call. use the latter (recommended) if you
    want to be able to feed the data in in progressive chunks.

  • each complete output line will be written to your downstream
    yielder as soon as it is determined; that is, if you are using
    the "session" technique the output is "streaming", "real-time",
    "progresive". even: this acts like a map-reduce (or -expand)
    filter.

    for this "session" mode you will need to call `flush` when you
    are done feeding it strings in order to output any remaining
    partial line it was in the middle of building.

  • this will try to do the right thing with hyphens in words,
    but it is not smart enough (nor likely ever will be) to figure
    out where to put new hyphens in words that didn't have them
    to begin with.

  • as a sort of corollary of the above, an output line will only
    exceed the width when a word is encountered in the input that
    is longer than the width -- this library has no special strategy
    for breaking such words up.

  • you can indicate a margin (any string) that is to be used at
    the beginning of every line. the margin's width will be counted
    just as if it is an ordinary token.

    if your margin width exceeds your argument width you will probably
    always get exactly one word on every output line for all inputs.

  • you can indicate a margin that is to be used on only the first
    output line.

  • you can indicate that the first margin is not to be output
    (although when provided it will always be counted in the
    width calculation).




## gripes

word-wrapping has had dedicated nodes in this universe going back to
late 2013. at the arbitrary moment of this writing we happen to be
finishing our (at least) third full rewrite of only the latest of
these nodes.

amazingly, word-wrapping continues to be byzantine no matter how
"elegant" we try to make it in each next rewrite. at first glance we
would guess it is because of the complexity of our desired behavior
near margins (different margins for first and subsequent lines, and
an option not to display the first margin), but the implementation of
this is localized to one or two spots.

no, it seems the complexity stems from the desired essential behavior.
tokenizing an incoming string is easy: we break it up into "word",
"spaces" or "dash" tokens. the messy part is all the conditionals for
these:

          at beginning of line  |  normally |  at end of line    | also
    word                    OK  |        OK |            OK      |  [1]
    space         IFF > 1 wide  |        OK | backtrack & remove |
    dash     gaping logic hole  |        OK |            OK      |

    [1]: IFF a word follows another word immediately
         and on the same line, add an artificial space




## notes from the aspect ratio node

### introduction to this node

given an arbitrary target aspect ratio and an arbitrary body
of text, try to "delineate" the text into the target ratio
with some sort of "best fit" algorithm that takes into
account an avoidance of "orphanic-ness".

note this stands in contrast to most word wrap algorithms
that simply wrap the words within a given fixed width,
creating a delineation that grows downward with more content:

this is a specialty form of word-wrapping whose delineation
grows growing downward and outward at roughly the same rate
as content is added.

as well we added correct behavior for breaking up words with
hyphens.



### "this formula" :#note-A

given the target aspect ratio and given the input content's
total number of 2-D "cels" (characters, points, picas;
whichever), we can make a *rough* guess at the result width
and height with a simple algebraic formula (solve for Q):

    the actual output area (rougly) =
      width aspect ratio component * Q *
        height aspect ratio component * Q

    area = width component * height component * Q^2

    Q^2 * width component * height component = area

    Q^2 = area / width component / height component

    Q = √ ( area / width component / height component )

the reason this guess will only ever be "rough" is:

A) there is the simple dynamic where each surface piece
   (space or non-space) has a potential length of zero to
   infinity, making the actual fit into a target width be
   "impossible" to predict without looking at each piece for
   a given target width; and:

B) there the dynamic where at each line break we don't use
   (but rather lose) the space surface pieces (always
   separators) if it's not the breakable zero-width location
   after a hyphen.

we have not proven but assume that the emergent behavior as
a product of the dynamics (A) and (B) together makes it
impossible to determine our "best fit" width and height with
simple algebra alone.

we presume there are other formulaic dynamics to this machine
with varying degrees of usefulness and accuracy:

1) there is probably a tendency as a corollary of (A) whereby
   as the target aspect ratio gets taller (i.e thinner) the more
   more space surface pieces will generally be omitted (because
   space pieces are discarded if they fall immediately before or
   after a line break). this tendency (if it exists) would count
   against our calculation for "area" above as some function of
   the ratio between space and non-space pieces in the input
   stream. however:

2) for any given delineation of any given input stream, every
   line that is not a perfect fit for the target width will
   "waste space" at its end and add verticality to the actual
   output rectangle, adding actual area beyond the area guess
   we came up with in the above formula.

although we have not proven this to ourselves rigorously, for
now we assume that to turn the above two theoretical dynamics
into code would muddy it at a cost greater than their
potential value.
