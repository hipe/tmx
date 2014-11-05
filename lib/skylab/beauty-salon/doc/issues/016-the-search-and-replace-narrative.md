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
