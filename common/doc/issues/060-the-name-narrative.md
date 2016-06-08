# the Name narrative :[#060]

## overview & intro to theory via a table of "standard libary" name functions

    | name conv. [family] name   | upcase ok? | trailing sep? | sep |
    | const                      |     •      |      •        | [1] |
    | lowercase with underscores |            |               | "_" |
    | human                      |     •      |               | " " |
    | slug                       |            |      • [2]    | "-" |
    | variegated name            |     •      |               | "_" |


### details

  • [1] any given const might use a combination of `CamelCase` and/or
    `Titlecase_with_Underscores` per [#bs-029], so there is no separator
    per se but rather a pattern or ad-hoc logic for separation.

  • [2] because slugs are used for filesystem names they need to
    "isomorph" with const names, and const names have that strange
    convention around trailing underscores (same reference as above).
    this phenomenon of trailing "separators" is something we only
    express in these two families and no where else.




# intro

imagine we have an instance of a class `FooBar` (or maybe it's
`Foo_Bar`). if we need to store that object in an instance variable,
then (all things being equal) a reasonable choice for the name of that
instance variable is `@foo_bar`.

imagine further that we have a simple reader method for this member
value. given the above, any developer familiar with the platform idioms
will be safe to assume that this reader method is named `foo_bar`.

the developer familiar with our own local "universe" idioms can safely
assume further that if one exists, the dedicated file for the subject
class is called "foo-bar.rb".

this fabricated but entirely plausible example produced *five* different
"surface names": `FooBar` (or `Foo_Bar`), `@foo_bar`, `foo_bar` and
`foo-bar.rb`.

but (of course) it is not the case that the participating developer needs
to remember each of these names individually. in fact when you read
the above strings, your brain (being the pattern-matching dynamo that
it is) probably read them all as the same "name", just "rendered" for
different contexts.

to put this phenomenon in terms that will be useful to us here, each of
these "surface names" is actually the same "deep name" merely
"inflected" for the each various "context" using a "name function".





the "name" that we are discussing here somewhat resembles the "lemma" and
"lexemes" of natural language in the sense that both are concerned with
regular patterns of inflection.

  • in the code we generally we discourage the use of the word "name"
    for any other sense than the sense discussed here, per [#bs-030]:A.

  • [#hu-037] is our dedicated node to natural inflection. although not
    a general introduction to linguistics, it is our closest node to it.


interestingly, here we do not (yet) offer a formal, concrete
representation for some sort of "deep name". really the "deep name" is
just the imaginary node floating in the middle of all these other nodes.

what interests us is how we can transform these "surface names" to
one another. our answer to this is the "name function":

  • it is an object

  • it represents a "name" in an abstract sense

  • it is built from the tuple of a "surface representation" (value)
    and "context" (reference).

  • it can produce or attempt to produce a surface representation
    for any other known context.

we achieve this thru something like adapter pattern slammed into factory
pattern ..




## implementation of translations

### judgement of implementation

this implementation is "better" than it was before but is still not
ideal. in the old way we had a single, monolithic class with an
ever-growing jumble of circularly referencing methods as depicted by
[#]/[figure 1].

in the new way, we make a subclass for each name-convention-category
(a somewhat arbitrary delineation), each of which:

  • ultimately descends from a common base class and

  • needs to touch that base class, if other names are to reach it.

(see [#]/[figure 2].)

the second point above is not pretty, but doing something like
dependency injection for something as lowlevel and ubiquitous as name
functions would incur complexity at too low a level.




--

EDIT: below is for old name that used to be in [hl]. subject node
was rewritten from scratch for [gv] and distilled up to here, but has
the same intent.


## upgrade path and obviation roadmap for old / new name

the below is for use with the obviation of [#ca-060] for [#ca-060],
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

    ./bin/tmx-cull survey reduce $PWD/lib/skylab/common/doc/issues/60

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
for the [#br-107] isomorphicisms, if it happens to work out that the name
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
