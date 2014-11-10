# the search and replace narrative :[#016]

## introduction

ostensibly this started as a one-off to assist us in the process of
[#017] doing a regular tranformation universe-wide across hundreds of
files. it very quickly grew in scope to something more.

below we will discuss why we didn't use `ack` among other points.




## scope of the task

at the time of this writing and exact match search for the the string
`::Lib_` found hits on exactly 555 lines in the codebase.




## comparative analysis

this is certainly a well-trodden space of solutions falling under the
umbrella of "refactoring tools" that are out there.

it is assuemd that certainly exist "better" ways to do this with tools like
Eclipse and probably emacs. but our state-of-the-art way to do this in
`vi` was really annoying:

1) with the "ack" utility we *can* use lookbehind assertions to match
   all occurrences of `Lib_` followed by "::" (but not actually match
   the "::" itself). we use the `-l` option to get a listing of the
   files only, not the line. presumably because of an issue with the
   Ack plugin for vi, we hackishly must indicate `-wl` (whole word
   match too).

   (ok we may not actually *need* lookbehind in this example, but we
   certainly have in the past. more on this below.)

2) we hackishly load the output of ack (the list of files) into vi's
   `args` command with the unforgivable series of steps:

   a) we copy the screen of text files into the pastebin buffer.
   b) we paste it into a new vi buffer (file).
   c) we use a search and replace "macro" that we have saved to some letter
      of the alpahbet we have to remember that strips the several leading
      pipes from each line and converts trailing newlines to spaces, leaving
      us with a (sometimes huge) line of text of filenames separated by
      spaces.
   e) we then copy *this* screen of text from (c) into `vi`, close the file
      indicating we don't want to save it, and we paste it so that it stands
      as the arguments to the `args` command.

3) we write a new "argdo" command, *rewriting* the (possibly complex)
   regex in a `s///` command along with our replacement expression,
   having to take into account the vi regex engine's differences,
   incompatibilities, and shortcomings when compared to the perl's PCRE
   engine behind `ack`.

     :argdo %s/\(::\)Lib_::\([^\[]\+\)/\1\.lib.(xxx)/gc | update

   note we have to make up for the lack of lookbehind by needlessly
   capturring the '\1' expression above.



### issues with the above approach

•  refining the vi-compatible regex can be difficult, because whereas
   writing the regex in a plain old '/'-style command shows you
   progressive, interactive feedback with whether you're matching
   anything in a file, this certainly does not happen (how could it?)
   with a command like "%s/foo/bar/gc"

•  if there are errors when we execute the `argdo` command, we have to cancel
   the operation for each file (possibly in the hundreds).

•  as the search and replace runs for each file, although we have the
   "yes/no" option on each replacement operation, immediate after the
   replacement is made the operation jumps to the next match, inhibiting
   us from seeing if the new string looks correct.

•  there is no easy way to save the operation for later editing and
   application.

•  we can't use *programming* in the replacement operation.




## why go around obstacles when you can plow through them?


our ridiculous solution to all of this is to write our own custom
solution. we expect that we will find a "better" solution than ours one
day, but we want to write it for ourselves first, getting it just the
way we want it.

also it's a fun excuse to play with the ridiculous space of terminal
interactivity.




### :#note-105

• these three "sections of context" (before, "lines of interest", and
  after) are represented superficially as line producers ("scanners"),
  which themselves can always produce an enumerator of array of lines,
  but first interface as stream-not-structure, in keeping with this often
  preferred interface for data that originates from some "outside"
  source.

• these three sections are always contiguous: each section's first line
  is always the line immediately after the previous section's last line.
  more specifically:

• what constitutes each of these section's first line (if any) is
  determined by the location of the delimiter of the last
  [of the previous section] except in the case where the first line of
  the section is also the first line of the file. this point,
  tautological as it may be, carries heavy sway on our logic.

  this is true regardless of (in the case of the middle section) whether
  zero lines of "before context" were requested.

  this will have the effect of us always "throwing away" one segment,
  when in fact we are using that segment just to know that it exists.

• a match's replacement is either engaged or not engaged, which is
  reflected in what is pre-rendered here.

• for any given match, both the original and the replacement strings
  contain zero or more delimiters (and there is no relationship between
  the count in the first and the count in the second).

• ergo the replacement string may have removed from or added to the count
  of the number of lines against what was there in the original.


within the scope of this function we define a tuple (family?) called
"segment" which:

  • is of category `normal`, `original`, or `replacement`

  • the tuple has a possibly zero length string that contains zero or
    one delimiter and if one, this delimiter occurs at the end of the
    string.

  • this tuple has a boolean component that indicates whether or not
    the string contains this delimiter.

  • if `normal` this tuple has an index into the "string" (the big
    original one).

  • if `original` or `replacement` this tuple has the index of the match
    (i.e which match it is) and if replacement an index into the
    replacement string indicating where this segment starts.

  • segments are currently produced three ways only:
    • by going forwards from a match (includes the match)
    • by going backwards from a match (excludes the match)
    • forwards from the start of the editbale string (i.e document).
    so, segments are produced contiguously and there is no random access.

the purpose of these segments is to bridge the world of "matches" to the
world of "lines": these two worlds exist in separate dimensions that only
intersect spuriously in that one cares about delimiters and the other has
them. without this abstraction the code becomes muddier.




### :#note-185

as offered in #note-105, each line must know where the previous line ends
to know where it begins. while looking backwards for context lines even
when we show zero lines here, we still need to find the segment with a
delimiter.




### :#note-350

don't use this method for general use, it is not future-proofy. it is
just convenient for testing, which is probably some kind of smell.
