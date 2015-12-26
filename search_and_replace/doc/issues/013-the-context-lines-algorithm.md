# the context lines algorithm :[#013]

(..continued from inline comments..)

with our linked list of blocks we can iterate from one to the next
asking each one to produce a stream of lines. but these blocks only
ever produce streams of lines that grow downwards from their top:

to say "give me only the lines for this particular match and the N
lines above it" will take some work, because the delineation of
lines is itself volatile being that it depends on arbitrary
replacement values that may themselves add or remove newlines.

(in fact internally the "matches blocks" produce streams of sexps,
not lines.) so these blocks do not out-of-the-box allow for random
access to output one match only, because that in itself is not
useful: match (replacements) are always expressed in the context
of full lines, and (until now) always in the context of a full
document.




## to start,

first, we'll be working with the block (not the match controller)
because matches out of context are not useful.

what we want is to say "give me (up to) the N lines before it and the
stream of lines that encompass this match only." the result shape
would effectively be a tuple of one array and one stream.

(imagine that we say "also give me (up to) N lines after the last
line that encompases the replacement expression.")
