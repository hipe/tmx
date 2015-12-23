# search and replace

## introduction

ostensibly this started as a one-off to assist us in the process of
[#bs-017] doing a regular tranformation universe-wide across hundreds of
files. it very quickly grew in scope to become an attempt at a reusable
utility towards this.

below we will justify why we didn't use a tool like vi's `s///gc` or
`ack` among other points.




## scope of the task

at the time of this writing and exact match search for the the string
`::Lib_` found hits on exactly 555 lines in the codebase.




## comparative analysis

this is certainly a well-trodden space of solutions (some decades old)
falling under the umbrella of "refactoring tools" that are out there.

we assume that there certainly exit "better" ways to do this with
whatver the "state of the art" IDE's and editors exist today. but the
"best" way to do this with our current editor (`vi`) was really
annoying:

1) with the "ack" utility we *can* use lookbehind assertions to match
   all occurrences of `Lib_` followed by "::" (but not actually match
   the "::" itself). we use the `-l` option to get a listing of the
   files only, not the line. presumably because of an issue with the
   Ack plugin for vi, we hackishly must indicate `-wl` (whole word
   match too).

   (ok we may not actually *need* lookbehind in this example, but we
   certainly have in the past. more on this below.)

2) we hackishly load the output of ack plugin (the list of files) into
   vi's `args` command with the unforgivable series of steps:

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

•  editing the search and replace terms variously can be cumbersome:
   it appears not possible to be able to paste into both of these; you
   have to chose one or the other. (yes they are effectively "sticky"
   but leaning on the back arrow key "feels wrong" and is cumbersome
   when you are refining a regex thru trial-and-error.)

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
   us from seeing if the replacement string looks correct.

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




## (notes from a child node)

### #note-321

we describe the behavior behind three similar buttons and justify their
individual constituency:

  • the "next file" button: clicking this button does two things: 1) it
    initiates a [dry] write of the changed file (if any changes were made.
    else it reports that there were no changes). 2) it changes the UI over
    to the next matching file.

  • the "skip remaining in file" button:

    cicking this button does half of what the previous button does and
    is useful for two things, one reasonable and one sad:

    1) if there is no next file but there are still remaining matches,
    we still want to be able to expose the same "write" behavior that
    the previous button exposes.

    2) (the sad part) just for sheer usability and the arbitrariness
    of the natural language we are herein hard-coding logic around,
    we don't want multiple executable buttons to each start with the
    same word (in this case, "next").

    because "next" is a strong idiom from our "mold" app (vi's '%s///c'
    thing), we won't just avoid using "next" altogether. as such, as
    well as under the conditions of (1) we also use this button in the
    cases where we would want a "next file" button but we are already
    showing a "next match" button. sometimes design is about nothing
    more than compromise within circumstance.

  • the "done with file" button

    it looks weird / is wrong to say "next file" or "skip" if there is
    no next file. so "done" is for these cases, where there is no next
    file and there are remaining matches (or not?) and we wish to write
    the file nd be done with it.

this whole note reveals a smell and opened up #open [#005].




### #note-372

in interactive mode when you are "within" this node it can behave as
though it has persistent state (that is, be "sticky"): the file being
edited can change the "current file" in this node and so on. each time
focus returns to this node it may need to be holding state from the
previous time it had focus: namely, the file it should be editing
around.

however if you ever ascend above this node we do *not* want its state to
be sticky: if you go "up" and come back down again, we want it to have
the appearance of being a fresh "session", starting again from the first
file. (this is an arbitrary design decision and hypothetically could
change.)

as such experimentally the way we accomplish this for now is for this
node to maintain its own run loop similar to (but maybe or maybe not the
same as) the run loop at the very top of the application.

"quit" is always easy because we just result in false-ish and it bubbles
all the up out of the request stack. with "up", however, it is tricker:
we release resources, break out of our own loop, and neded to change
the focus of the main loop.
