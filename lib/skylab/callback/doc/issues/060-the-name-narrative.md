# the Name narrative :[#152]


## upgrade path and obviation roadmap for old / new name

the below is for use with the obviation of [#hl-152] for [#cb-060],
and the cull survey that can be found there. running [cu]`s
"survey reduce" action against the survey there (which points to this
file here) will produce interesting information from the below table.



  the feature             | old                   | new
  local_normal            | same                  | as_variegated_symbol
  as_const                | same                  | as_const
  as_method               | same                  | as_lowercase_with_un..
  as_natural              | same                  | as_human
  as_slug                 | same                  | as_slug
  via_anchored_in_module_name_module_name| yes    |
  local_normal_name_from_module | same            | via module [..] as etc
  const_basename          | same                  | happens in via module
  constantify             | same                  | via v.s as const
  naturalize              | same                  | via v.s as human
  humanize                | same                  | via const as human
  normifiy                | same                  | via const as lcwu
  slugulate               | same                  | via v.s as slug
  variegated_human_symbol_via_variable_name_symbol | same |
  labelize                | same                  |
  module moniker          | same                  |

this:

    ./bin/tmx-cull survey reduce $PWD/lib/skylab/callback/doc/issues/60

will show you only the list of unique features. we have written the
table in line with our goal: we include those features that exist in the
old that do not exist in the new. we do not bother doing the opposite,
because we have no doubt that we are keeping the new and
shrinking/moving the old. because of this one-sidedness to the table,
the list of unique features produced by the [cu] report presents to us
those features that should remain in the old (which ultimately the whole
node will be moved to live under the new as an auxillary node).

for all of the rest of the above functions and methods, the
corresponding value in the new gives us the upgrade path from the old,
so we can (with some trouble) free ourselves of even the implementation
of the old.




## :#storypoint-5 introduction

a name "function" may be a bit of a misnomer, it is really several functions
in one, bound around (or curried to) an inner "normalized" name. abstracted
from existing application here, it comes in handy for doing name "inflection"
for the [#146] isomorphicisms, if it happes to work out that the name
function(s) you want are here.



## :#storypoint-10

the functions defined here may have sister variants found elsewhere in the
system but these are more specific and less general-purpose.







## constant names can hold information that some others,

not all name conventions are cleanly isomorphic with each other.
converting from const to norm can be lossy, for example:
`NCSA_Spy` -> `ncsa_spy` - it is impossible to go in the reverse direction
deterministically



## :#storypoint-35

so that this name function can look like a full name function, if you want
to future-proof your name function but for now only use a const and not a
deep graph.



## :#storypoint-55

a "compound name" made up of multiple monadic names. usually used to represent
a "fully qualified" name, which can then be turned into a variety of
derivatives.



## :#storypoint-105

centralize this hacky fun here
