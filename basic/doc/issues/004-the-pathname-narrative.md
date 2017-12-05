# the pathname narrative :[#004]

## introducton

the host platform of course has a "pathname" class that is one of the
most widely used stdlibs in this universe. (at present it is the only
one that we pull in universally).

here we certainly do not seek to replace it. rather we complement it
with *normalization*-related facilities that *do not* ever rely on the
filesystem. any time a method here would incur a hit to the filesystem it
*MUST* not live here but should live at to [#sy-009] the filesystem node
or a child node of that node.




## #todo DETACHED (was #n-ote-010)

(this is just a detached notion that we may or may not ever use)

this is *NOT* for detecting whether the string models a valid path in
the eyes of your filesystem. that is for your filesystem alone to decide
and is decidedly of no concern to us. rather, this is for helping you
decide if you think a path "looks" "sane" based on these criteria of
sanity.

• spaces - the path cannot contain any whitespace characters at all.

• special characters - the following characters (that usually have special
  globbing, expansion, job-control, redirection etc semantics in shells)
  may not be used anywhere in the path. we reserve the right to expand
  this section arbitrarily at any point in the future, making this whole
  definition not future-proof in any way :P

    ? ` $ ! & * ( ) = [ ] | \ < > ?

  note that for now we have allowed '{' and '}', which to our (z) shell
  appear not to have special meaning on their own.

• path separators - we disallow for now all characters used as path
  separators on any OS that we know about so far, so ':' and ';'

• pathpart separator - the pathpart separator ('/' on any OS we care about)
  may occur at the beginnng, end and (of course) middle of a path, but may
  never occur multiple times contiguously. this is just because it looks
  ugly and creates more normalization work, and sometimes it is an early
  warning that a path was built programmatically with a part unintentionally
  missing that wasn't checked for more roubstly.

• dashes - no pathpart may ever start with a dash (nor would one be
  allowed to have a dash followed by a whitespace character, were we to
  allow those but per above we do no). one or more dashes may occur
  anywhere else in a pathpart.

• the '.' symbol (meaning present working directory) may only be used
  either as a standalne path (that either is or is not followed by the
  separator sequence (usualy '/') and nothing else) -or- it may be used as
  a decoratively explicit start to a relative path, so one that starts
  with "./" and has something after it. i.e the standalone dot as a
  symbol may not be used elsewhere, like in the middle of paths or at
  the end. (but to be clear this says nothing about dots as a healthy part
  of a complete pathpart: such pathparts are not made invaid by the
  presence of dots). our reasoning is again one of both aesthetics and
  reducing normalization work at this imaginary stage.

• the '~' may only ever occur at the beginning, either as a standalone
  pathpart or as the first character of the first pathpart of a path
  with one or more pathparts. (it has special meaning but may be useful
  to us under the umbrella of "sane paths").

• the '..' symbol (meaning "go back a directory") may occur as one or
  more pathparts but only contiguously and anchored to the beinning or
  immediately after the the single dot pathpart described above. (again,
  we just don't want too much abnormality at this imaginary stage.)

  ergo this operator may only be used on relative paths and only
  anchored to their beginning or after itself.


we are not sure, but we *think* that if these rules are applied to
filter out those paths that are not covered by them, then those paths that
remain -- that is, the set of all paths that pass the above rules --
do not need special escaping to be executing in a shell ... MABYE!
