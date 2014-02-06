# this git gotcha :[#035]

(the TL;DR: is 2nd to last paragraph.)

the two scripts that are sibling to this file are minimal pairs that present
what we considered surprising behavior at first: the SHA's produces by a
"git log --follow" do not necessarily each contain diffs that touch the
argument path (depending on your meaning of "touch").

if you "source" each of the scripts, and with each repo created by that script
do a "git log --follow -- twozie", in one of the repos you will see three
resultant SHA's (the "cray" one), and in the other repo (the "norm" one) you
will see only two.

in the "cray" one, the first commit produced by the 'log' command will not
actually have in its delta any effect on the file, however note that SHA was
still a result of the 'log' command.

the reason for this (we presume) is the content of the participating files,
which is highlighted in the difference of the "minimal pair" of the two
scripts (yes do a diff of those to see the difference):

if one of the files "looks like" the other file in a subsequent commit, git
perhaps want to highlight to you that this could be mistaken for a move, but
it is not (or it is; however it is you are supposed to interpret this).

if you think that this is an overblown explanation, please appreciate that
we lost almost a whole day narrowing this down (we thought it was due to an
issue with our build scripts; it was not); so we write all as a bit of a
victory dance, celebrating the triumph over our ignorance of git.

if you have no idea what is meant by all of this (e.g because you're me a few
weeks from now), then suffice it to say the uptake of it is that the set of
all SHA's that affect a file are (we think) a *subset* (e.g the same set)
of the set of SHA's in the output of a "git log --follow" for the path of the
file.

(the funny part is all of this has us wondering now what a file really is.)
