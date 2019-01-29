---
title: "the toml adaptation"
date: 2019-01-27T23:53:00-05:00
---



we chose toml over yaml because its forced simplicity and universality
is a good fit for the orientation of this project.

we think yaml looks nicer.

we aren't totally sold on toml.

we want to support different format adapters in a plugin way, etc.


## broad provision 1

it is certainly not the case that this is meant to work for all toml documents.
our variant of toml is stricter than the official spec to scale it down to be
applicable to exactly our use case and perhaps a few outside of it.




## broad provision 2

to make "crude" (fast) parsing easier on us, we are going to be very
line-centric. this means that for now multi-line doo-has may be out
but later for that.




## provision 2.1

when possible we will hackishly use the first character of the line to
determine what kind of line it is..




## broad provision 3

there's a time and a place for the many layers of validation that can be
done. for certain functions we're going to err on the side of doing things
the optimistic way unless strict validation is the objective of the
operation..

(sub-provisions of this occur further below because they are usually
refinements to a pseudo-algorithm offered below.)




## breaking down CRUD (which is the whole thing)

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

(you may find this set of verbs acronymized as "CUD" in the code, out of
deference to its forebear.)

our approach from here forward will be to apply the _idiom_ we have chosen
for how we edit files; namely, as a stream of lines (and not, say, as a
matrix of bytes; a distinction that from one level may seem arbitrary but
at our level is everything).

for better or worse (and this is VERY likely to change) we can perhaps
distill all of our sub-categories of mutation into two categories of
implementation:

  - those that can be modeled in terms of replacing the one or more lines
    of an existing entity with zero or more arbitrary lines ("REL" for
    "replace entity (with) lines").

  - those that can be modeled as an act of _appending_ one or more lines to
    the zero or more existing lines of a file.

what informs this approach is the RISC-style of labor decomposure, where
you have a relatively small set of operations that can do "heavy lifting"
which can be used to compose each of a relatively larger set of higher-
level operations.

again this is all subject to change, but we *think* we can use just this set
of two fundamental operations to implement what constitutes our entire
imagined suite of mutating operation use-cases.

first we introduce the mutation cases alone (ordered roughly in by imagined
complexity, ascending) ("N" means "some _nonzero_ positive integer"):

  - a CREATE that amounts to appending N lines to a totally empty file
    (in effect either creating a new file or updating an existing
    zero-byte file).

  - a CREATE that amounts to appending N lines to a file with nonzero lines
    but one that has no entities (i.e. a file with only comments and/or
    blank lines). (depending on what day it is, such a file may or may fail
    the grammar of even our "coarse parse", but more on this below.)

  - a CREATE that appends N lines to a file that already has entities.
    (this is to say you have to know in advance that the entity belongs
    at the very end of the file. in such cases you *can* attempt a no-parse,
    simple line-stream-based operation of concatting two streams.)

  - a CREATE that inserts a new entity immediately before some existing
    entity (given the identifier of the existing entity).

  - UPDATE an existing entity. (change an existing N lines to some other
    set of N lines (perhaps with some no-change pass-thru).

  - DELETE an existing entity. (change an existing N lines of an entity
    to 0 lines). note we should pay attention to if it's an issue if we
    create a logically or physically empty file where once there was not
    one before. (to be complete we might want to break this into three
    cases.)

so one thing is, there's six categories above that we think cover every
conceivable case of collection mutation; but the ontology of it is a bit
arbitrary. for example, the final case actually describes at least three
sub-cases. as for updating existing entities, there's lot of sub-cases
that would warrant individual attention, like updating-vs-creating
attributes, deleting every attribute of an entity, what to do with
whitespace and comments, etc.

(indeed in the tests you can see quite clearly the sub-dividing of the
above ontology.)

fortunately, all the sub-dividing of cases is out of scope for us here,
because our objective here is actually the opposite. let's *reduce* this
ontological (and hopefully comprehensive) constituency down to only the
reduced-instruction-set of operations we described at the top.

now we'll go thru the above six categories and offer how they *could*
each be implemented using only our two "elemental" operations.
(again "REL" stands for "replace entity with lines").

| case | RISC-y operation |
|------|---------|
| append to truly empty file      | concat two streams |
| append to file w/ no entities   | concat two streams |
| append to file w/ entities      | concat two streams |
| insert N lines before ent w/ ID | REL |
| update existing entity w/ ID    | REL |
| delete existing entity w/ ID    | REL |

the above is purely conceptual. the main point of it is to show that (as
far as we can tell) our whole mutation ontology (in whatever form it takes)
can be implemented on top of these two fundamental operations (ignoring
for now a bevy of challenges that come with "update").

one side-note is how we would implement "insert new entity immediately
before existing entity". we would do so by using the "replace existing entity
with lines" function, where the lines with which it replaces the entity
are first the lines of the new entity, then the lines (unchanged) of the
existing entity. this is perhaps the most complicated implementation in
this conceptual implementation (also it's a bit of a hack for the sake of
RISC).

alternately, what if we tried to do this all with a souped-up state machine.

  - we would need one action that is called at start, before any first line
    is pulled off the stream, so that we can set up a listener so that with
    _every_ line we traverse we are able to add it to a buffer.

  - add to the at writing current state machine a transition from the
    start state to the done state to accomodate all the kinds (two) of
    empty-ish file (and even non-existent files).

let's return again to our top level ontology (the "CUD"):

  - create
  - update
  - delete

but this time, we'll imagine how we would attempt the rewrite of the file
using parse actions in our state machine.

  - CREATE: we'll assume that the entities are placed in the file in order
    by the identifier of the entity, in lexographic order ascending. (if
    the existing entities are out of order this algorithm won't totally bork
    but it should be seen as GIGO.
    it just won't sort the file for you when it's not already sorted
    traverse the zero or more existing entities in the file, doing this:

      - take care that any leading whitespace/comments in the file are
        emitted as if it's its own entity, always first.

      - if the existing identifer is less than the argument identifer
        (lexographically or numerically as appropriate (watch for letter
        casing!)) simply flush all the lines in the input buffer (in effect
        passing the entity thru).

      - otherwise, if the existing identifier equals this one, fail.

      - otherwise (and the existing identifier is greater), then we have
        found our magic moment: emit first the lines of the argument entity,
        then flush the lines in the buffer (the lines of the existing entity).

      - once you have emitted the argument entity, every next entity
        we traverse is simply emitted by pass-thru.

      - if when you reach the end of the file (you pulled the last line off
        the stream, or found that the stream started out as empty), check
        that you have emitted the argument entity. if not, do so. (this
        might be accomplished thru function variables rather than
        conditionals.)

    this algorithm should cover the first 3 of our arbitrarily 6 cases.
    (that is it should work for literally blank files, for effectively
    empty files, and for files with entities (but also be sure you test
    for three kinds of insert there!).)

  - for UPDATE, similar to above but rather than searching for the first
    entity that's greater, you're searching for the first entity that's
    equal. updating attributes is a whole big painful thing, but for our
    purposes here all we're concerned with is replacing one set of lines
    with another at a particular point in the file. most of the points of
    the previous section hold.

  - for DELETE, same as UPDATE, but the lines you replace them with is the
    empty stream.

that's it! let's see..




## provision 3.1

for a RETRIEVE, if the file has duplicate identifiers or its entities are out
of order, then formally it is invalid and the behavior is undefined and must
not be depended on.

in practice (and at writing) probably what would happen for a RETRIEVE is
that any first matching entity will win (the one that starts on the lowest
line number); and if there's duplicate identifiers then this invalidity
won't be detected on a RETRIEVE. but this behavior must not be assumed or
depended on.




## provision 3.2

for a CREATE, if the file has its entities out of order then it is invalid
and the behavior for this operation is undefined.

in practice (at writing) what would probably happen is exceptionally bad:
as soon as the top-to-bottom traversal of the file encounters a document
entity that "is greater", it will do a mode-change right then and there
and insert the new entity before the current one. this could make the
out-of-order-ness worse depending, but worse than that this could miss the
fact that there is already an existing entity in the document with that
identifier, a behavior that is normally provided and avoids this manner
of critcal corruption.




## provision 3.3

for UPDATE and DELETE, the same concerns with provision 3.1 apply and so the
same general provision holds: formally the behavior for these verbs is
undefined if the document is out of order or has duplicate identifiers.




## future feature 1

the meta section




## future feature 2

dotted keys (non-flat)




## future feature 3

maybe some kind of schema representation for the purpose of
valid key sets, possibly type, and attribute ordering.




## (document-meta)

  - #born.
