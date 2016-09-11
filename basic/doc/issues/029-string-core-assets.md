# string core assets

## unindent :#note-01

the purpose of `unindent` is to allow us to write those HEREDOC's that
are part of tests (the 95% case of our HEREDOC's at least) to be
indented with the same arbitrary indent of the surrounding code,
while (in effect) not actually indenting the actual produced string by
that indent. it's a tradeoff whose cost is the overhead of this
method and whose benefit is avoiding a nasty hit on readability.

if we wanted to be really thorough about it, we would traverse over
every nonzero-with leading whitespace string of every line, finding
that which is the narrowest, and use that amount to unindent the
string by. but this is relatively expensive (requiring that we build
a string scanner and do some simple statistics); and in practice such
strings with a jagged left margin whose first content line does not
start at the margin; these are 1% rare or less (perhaps not even
occurring yet ever in nature).

SO for the first several years of this function's lifetime, our
algorithm was simply to match the leading whitespace *anchored to
the beginning of the string*, and use that as the determiner for
what the indent is. and this hummed along nicely for all those years.

but life changed when we started trying to make fixtures of `git`
process outputs. you see, some `git` commands (but imagine it's
anything) output *meaningful* leading blank lines in some of their
output (for example, the result of a `git show` command used and
committed #at-this-writing.) as such, our simple algorithm no longer
works for these strings when they are part of our unindenting HEREDOC's.

since we really want them to be (because we find the workarounds ugly
along variety of axes), we modify our algorithm as such: we find the
first line *with content* and use *its* leading whitespace as the
determiner of what the indent is.




## tombstones and commit markers

(do not ever change the lines below as long as they are still referenced above.

  - #at-this-writing we added fixtures for certain `git` commands.
