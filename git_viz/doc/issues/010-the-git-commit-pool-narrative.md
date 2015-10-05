# the git commit pool narrative :[#010]

(EDIT: this is archival. we may re-promote it to ordinary relevance in
the future, since all of its content is concerned with semantics.)


## #storypoint-30 what is the deal with commitpoint indexes?

a commitpoint is not a commit, it is a point on a line. although it exists
one-to-one with a commit, the commitpoint should be thought of as a discrete
point in time on which significant events happen. (also, because commits are
propbably more usefully thought of as nodes in a directed graph rather than
points on a line, our neologism explicitly de-emphasizes this non-linearity
and emphasizes this one particular (perhaps constructred) scalar property of
commits).

we almost called this an "eventpoint", but since there are no forseeable
events that are not commits in the eyes of "git viz" (gv), we stuck with the
name "commitpoint", with the rationale that it is a bit more semantically
mnemonic (but like everything, this name is subject to change).

also, a commitpoint may or may not have representation in the code. the point
here it is that whether or not concrete, it is an abstract concept used in
naming and in logic (that is, in our minds).

commits are never represented in gv without being in the "pool". the same
commit is never represented by more than one commit object. (this is a bit of
a nod to datamapper, if you remember that.) this is part of the reason why
they are immutable, also why they are kept in a pool.

after we have gathered all of the commits (and as mentioned, they are all in
the pool), we then make an an index of them that is sorted by some
chronological criteria, «for now author date.».

now we have a list of all of the commits in some chronological order. the
commitpoint index, then, is simply the index of that commit in this list
(the chronologically first commit has a commitpoint index of 0).
