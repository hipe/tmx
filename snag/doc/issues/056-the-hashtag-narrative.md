# the hashtag narrative  :[#056]


## introduction

we broke "hashtag" out from "tag" in two phases, separated by months.
the first phase was a clean re-write of "tag" but only for parsing
hashtags (in the more traditional sense) for another application. we
didn't even integrate this new sub-library in with its native
sub-product. the second phase involved integrating the new library and
removing redudancy from the old library.


the reason they are left as spearate entities is because 'tag' is a lot
heavier and has a lot more business-specific nerks that wouldn't have as
much general applicability.




## :[#here.B]

the third and every subsequent time we re-build a piece, we re-use one
of the first two pieces we built, alternating which one we use
("round-robbin flyweighting").

the reason we use flyweighting at all is that for datasets of any
significant size, without flyweighting there would be a grossly
inappropriate amount of wasted memory and memory allocation overhead as
we make thousands or millions of objects we don't need and will never
use:

for example, in the commmon cases where we are only searching for
business objects tagged with a certain tag, we do not need to create
dedicated string pieces and tag pieces for all those business objects we
are scanning over.

even in cases where we are outputting *every* business object to output,
we can do this with just six "piece" objects instead of millions (2
string pieces, 2 tag pieces, 2 newline pieces). in such a case we can
accomplish identical behavior (and probably faster) by using our 6
objects in a heavily flyweighted manner rather than allocating millions
of them.

the reason we use this rotating buffer approach (with N number of
flyweights and not one) is because for some algortihms used here, we
*do* need to do a "peek" lookahead, and it's convenient to use the piece
objects for this.

the reason that "N" is 2 is because that how many items we need to hold
simultaneously to do our lookahead logic. if "N" became 3 or more, this
would be trivial to add but would require re-working the code.
