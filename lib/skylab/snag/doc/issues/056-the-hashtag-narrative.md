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


## :#note-25

this ugly little thing exists so that we can have scanning as per
normal but while doing so, peek ahead to view any "values" that the tag
may have been associated with, if this is desired.
