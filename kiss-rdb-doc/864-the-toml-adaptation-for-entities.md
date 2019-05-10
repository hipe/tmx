---
title: "the toml adaptation for entities"
date: 2019-01-27T23:53:00-05:00
---



we chose toml over yaml because its forced simplicity and universality
is a good fit for the orientation of this project.

we think yaml looks nicer.

we aren't totally sold on toml.

we want to support different format adapters in a plugin way, etc.
(see [#854] plugin architecture (visualization).)


## broad provision 1

it is certainly not the case that this is meant to work for all toml documents.
our variant of toml is stricter than the official spec to scale it down to be
applicable to exactly our use case and perhaps a few outside of it.

EDIT:

there are things we could store but that we don't want to because
they wouldn't be "pretty".
as a design decision towards our intended use-cases (and also as a
pratical matter where it touched on performance); the system will be
opionionated about some things.

there may even be some heuristic limits so that things are kept
adequately "pretty"..




## broad provision 2

to make "crude" (fast) parsing easier on us, we are going to be very
line-centric. this is why our first pass at this did not support
.[#867.J] multi-line strings...




## provision 2.1

when possible we will hackishly use the first character of the line to
determine what kind of line it is..




## broad provision 3

there's a time and a place for the many layers of validation that can be
done. we're going to err on the side of being optimistic
unless strict validation is the objective of the particular operation..




## collection edit theory ("CRUD")

we'll use the familiar acronym "CRUD" as a startingpoint in creating an
_ontology_ for how we can persist new entities or persist updates to existing
entities in our persisted collections. "CRUD" stands for:

  - create
  - retrieve
  - update
  - delete

of those four categories of operation, consider which ones require that we
mutate the file versus which do not. the answer is that only RETRIEVE is
"read-only", whereas the other three require that we change the file.

(sidebar note on style: we capitalize the verbs when they appear inline in
paragraphs in the hopes that this will look most familiar to people used
to seeing verbs like this capitalized in the context of SQL (but note we
say CREATE and not INSERT in this discussion).)

retrieving is a mostly solved problem at this writing (at the sub-file level
anyway), so we can omit it from this discussion. so the remaining categories
of interest to us are:

  - create
  - update
  - delete

we acronimize this set of verbs as "CUD" in the code and perhaps document
titles, in deference to its forebear.




## <a name=C></a>CUD+RT breakneck breakdown

- this table splays out (on two dimensions) a condensed oveview of
  implementation considerations across our five fundamental operations:
- **CUD+RT**: CREATE, UPDATE, DELETE, RETRIEVE, TRAVERSE
- both axes include mechanics etc not yet introduced
- generally when an operation has more X's it is more complicated

**columns legend**

- **file?** whether the entities file must first exist ("-" means _yes_)
- **ID?** whether you must pass an existing identifier to the function
- **attrs?** whether you must pass name-value pairs to the function
- **Mx File?** whether the entities file is mutated
- **Mx Index?** whether the index file is mutated


|CUD+RT|file?|ID?|attrs?|Mx File?|Mx Index?|
|---|---|---|---|---|---|
|traverse|-|-|-|-|-|
|read    |-|X|-|-|-|
|update  |-|X|X|X|-|
|delete  |-|X|-|X|X|
|create  |X|-|X|X|X|

**mini-conclusion**

- the operations towards the top are indeed generally easier to implement.
- DELETE and CREATE are the only two that mutate the index file.
- (they are probably the only two that read it, too.)
- we infer from looking at the table (but also we know empirically)
  that CREATE is the most complicated: not pictured is that CREATE must
  provision a new ID.
- not pictured is the more complicated edge cases of creating the first
  and deleting the last entity in a collection.




## file edit theory

the previous section presented a breakneck-pace, super-condensed, high-level
summary of considerations for implementing our five operations.

here we come from the other end and think about the fundamental properties
of the space we're exploring, and then we build back up from there. okay:

we'll say for now that the persisted state of a collection _is_ its
representation in its one or more files, axiomatically. ([#853] "filetree
schemas" explores this with more breadth.)

when everything is right in the universe, we don't have to give very much
thought to "how we think about" files; they "just work". but for our purposes
here, we very much have to think about how we think about files.

there are different ways one can think about the data in a file:

  - you can think of it as an array of bytes
  - you can think of it as a matrix (table) of bytes
  - you can think in terms of _characters_ rather than bytes
    (think Unicode codepoints)

and so on. it becomes this teleological discussion: what _is_ a file?
is it really bits not bytes? is it really just electron charges on some
solid state storage medium? etc.

to us we like to think in terms of "isomorphisms" (see information theory
broadly, or Douglass Hoffstader's G.E.B more specifically, or don't):
we can translate between these different _idioms_ of thinking of files
_losslessly_, so we should do so according to what is practical:

if it's useful to think of the file as a matrix of bytes, do that. if it's
useful to think of it as as stream of Unicode characters, do that. if two
idioms are indeed isomorphic, then they're two-way lossless and we can jump
back and forth between them as it becomes useful. perhaps we employ different
such idioms at different levels of abstraction, maybe even concurrently.

there's even an _ontology_ of _idioms_ here: idioms for working with files
seem to fall comprehensively into exactly two categories: stream-like vs.
tree-like idioms.

so finally:

  - we think of a file as a stream of lines (mostly).

indeed the theory we have laid out here sets the stage for a huge part of
this project: parsing, which can be described as the process of forming
higher-level streams of symbols from lower-level ones (and frequently
those higher level streams are streams of trees!).




## algorithm theory

above we introduced our "collection edit theory" of "CUD" and then introduced
our "file edit theory": that the main _idiom_ we will employ when working
with files is seeing them as _streams_ of _lines_.
(be advised this will get more nuanced at #wish [#867.J] multi-line strings.)

here we synthesize those lexicons towards this document's objective:
our algorithms for the CUD of entities in files.


the tradecraft of software algorithms certainly falls under the rubric of
engineering's familiar game mechanic of trade offs: algorithms are formed at
the intersection of competing forces like memory usage, execution speed, and
code-value (code-value, in turn, being stuff like cost of maintenance
from things like readability, DRY ("don't repeat yourself")).

here our approach is guided with an eye towards DRY/code clarity and
adjacently on memory usage. we hope to get sane execution speeds on small
collections but that's a tertiary concern right now.




## operation composition theory

(this is a much-condensed version of ideas archived at .#history-A.2.)

one approach we can apply towards our implementing of CUD'ing entities is
what amounts to plain-old-programming, but something we give the fancy name
here: "operation composition".

the idea is that much like the RISC architecture tried to improve on the
x86 architecture with a smaller set of building blocks that can somehow
combine to "do more", we can theoretically implement our CUD operations
by composing them from a small set of simpler operations. for example:


| case | RISC-y operation |
|------|---------|
| append to truly empty file      | concat one stream after the other |
| append to file w/ no entities   | concat one stream after the other |
| append to file w/ entities      | concat one stream after the other |
| insert N lines before ent w/ ID | replace entity with lines |
| update existing entity w/ ID    | replace entity with lines |
| delete existing entity w/ ID    | replace entity with lines |

the above proposes that we can implement these six cases (and probably more)
with only two underlying operations (with different inputs).

this is only illustrative - although we employ the principles behind them,
at writing we do not actually employ these particular algorithmic suggestions.

the point is just to show that if we develop a small set of reliable,
well-tested building blocks, we can combine them to compose a broad
swath of our implementation with hopefully a smaller surface area.




## synthesis

here we make a crude sketch of very high-level notions of how CUD could
go, while lining up the sketches in an intentionally narrative order:


### delete

1. output the zero or more lines above the span of edit
1. do nothing - i.e don't output anything for the span of edit
1. output the zero or more lines below the span of edit


### create

1. output the zero or more lines above the span of edit
1. output the _one_ or more lines of the new entity
1. output the zero or more lines below the span of edit


### update

1. output the zero or more lines above the span of edit
1. output the _one_ or more lines of the entity _after having been modified_
1. output the zero or more lines below the span of edit


now we look at these three through a series of lenses and see how they
compare and contrast. the lenses are:

  - DRY
  - prerequisite entity presence or absence
  - determining new entity lines as necessary
  - a clever composition

first, DRY: note that each of of the three sketches has the same step for
step 1 and step 3. we'll just keep that in mind for now. so the remainder
of the discussion can focus on each of the sketch's respective unique step 2.

prerequisite entity presence: to CREATE, the entity must _not_ already exist
(by ID). for UPDATE and DELETE, the entity must _yes_ already exist by ID.

as a very practical and somewhat low-level matter, what becomes an important
question is where new entity lines come from (if applicable):

for CREATE, we don't really have to care where the new entity lines come
from, they can just be passed as an argument (as long as we know the new
ID of the entity we are creating).

however with UPDATE as it has been intentionally designed, you can't know
the new entity lines until you _feed the existing_ entity into a function;
and you can't know _that_ entity until you get to it. this is all to say
that UPDATE is the most complicated of all these (but fortunately it's
not that complicated).

finally, a clever composition: note that we can implement DELETE as simply
a special case of UPDATE, one where the new entity lines is the empty list.

(at writing we do _not_ do the abstraction suggested by the "DRY" lens
above, nor do we do the composition suggested by the last lens; all by
the rationale that this would hurt code clarity more than it would help
anything.)




## future feature 1

the meta section




## future feature 2

dotted keys (non-flat)




## future feature 3

maybe some kind of schema representation for the purpose of
valid key sets, possibly type, and attribute ordering.

(3.2 is inline tables, 3.3 is arrays.)




## future feature 4

.[#867.J] multi-line strings...




## (document-meta)

  - #history-A.2: pretty big edit, including bury provisions about no validate
  - #history-A.1: remove discussion of why we want blank files
  - #born.
