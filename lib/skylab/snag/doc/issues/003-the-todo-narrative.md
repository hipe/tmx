# the TODO narrative :[#003]




## #note-85

given a `full_source_line` that looks like:

    "      # %todo we would love to have -1, -2 etc"

parse out ranges for:

  + `non_comment_content`  : the leading whitespace before the '#'
  + `commment_content` : the string from 'we' to 'etc'

some of these ranges may be zero width so it is *crucial* that
you check `count` on the range because otherwise getting the
substring 0..-1 of a string may *not* be what you expect, depending
on what you expect!



## :#note-75

we keep the logical redundancy here intact because this:
just because all these ranges are implemented in the same manner doesn't
mean they have to be.



## :#note-100

consider the line:

    @full_tag_string = "##{ @tag_stem }"  # %todo make the '#' be a variable

what we want (for starters) is a matchdata holding the offset and width
(or `begin` and `end` offets if you prefer) of that there first occurrence
of our pattern, in this case '%todo'.

it's kind of annoying and sad that we re-search for the first occurrence
of the tag. maybe there is a way to get the offset and with of the match
from `grep` or whatever system utility is used, but on the other hand it
would expose us to more dependency on the specifics of those utilities &
make the system fragile.

but that's not even the really annoying part:

for what we want with melting todo's out of source code, it is useful (if
not necessary) for us to break this line up into several parts:


    <--[..]---------- code content ----><-><-----><------------------------>

there are four segments above. the first segment, the "code content",
always starts at offset 0 and goes (in our example) up to and including the
end quote of the quoted interpolated string. it does not however include the
(in the example) two spaces following it and preceding the '#' that starts
the comment line.

some gotcha's:

+ there may or may not be anything before the first comment character of
  the line. that is, maybe the line only contains a comment, that starts
  at offset zero.

+ the comment character may or may not also be the starting character of
  the tag (this practice is frowned upon but not strictly enforced here.)

+ there may or may not be a nonzero-width 'body' part after thee tag.


our `s` variable holds the string from the beginning of the line up to
but not including the first '#' ** used in the "%todo" ** tag (if any).

now, if this character that starts the tag is in fact a '#' it may or
may not have also been used as the character that starts a comment. the
way we determine that is this:

backwards from our position of where

  # this is up to but not including the
        # first occ

we need to go back up till before the '#'

