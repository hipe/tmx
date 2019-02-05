---
title: "the toml adaptation for attributes"
date: 2019-01-28T02:25:00-05:00
---

## objective & scope

describe (roughly) an algorithm for CREATing, UPDATing, and DELETing
_attributes_ in/from existent document enties; or creating such entities
in the first place, in terms of how a dictionary of key-value pairs can
translate into a stream of lines.




## introduction to the problem

CUD'ing the attributes of a document entity introduces new problems not
present in the equivalent operations in a relational database or even a
document-based/"schema-less"/"nosql" database because not only do we have
the linear composition of the existing document entity to preserve
(including existing comments and blank lines) and not only do we have a
new composition (order) to determine deterministically, but we have
all the craziness of our comments provision to worry about.

the provision is something like this: when machine-editing a document,
we never want to break an existing association between a comment line an
attribute (key-value) line; and as far as the machine is concerned, this
association exists (or might exist) if the comment line and the attribute
line are touching (in either order).

most of the algorithmic work, then, in this docuement (and its counterpart
asset) is concerned with checking this comment provision, working around it
where possible, and the deterministic determination (eek) of groupings and
insertion points for CREATE (explored below).




## summary of relevant excerpts from the TOML spec

  - source: [the TOML github page][link1].
  - its explanation of comments (straightforward) is relevant to us.
  - quoted keys are supported but we are explicitly disinterested in them.
  - probably we want dashes not underscores for key names.
  - probably we will do casing the way we do with document names,
    so acronyms must be uppercase but nothing else can be.
  - we will probably end up allowing digits but at first perhaps not.
  - dotted keys are terrifying but interesting. later for that.
    (future feature 2)
  - defining a key multiple times is invalid to them (thank goodness).
  - the whole multi-line basic strings thing is interesting
    and potentially useful but this seems to be a in direct
    conflict with provision 1. (we would break tons of stuff, grammar change.)
  - literal strings are surrounded by single quotes.
  - what we've been calling "sections" they call "tables".
  - inline tables are interesting but we can't.
  - array of tables is nuts.




## CUD'ing attributes - overview

  - superficially this is going to seem similar to [#864] how we
    how we CUD entities in a document. (and certainy, deep down there's
    a lot of crossover.)
  - but for now we will resist the urge to early-abstract it because
    we can just imagine the API tangle that will become.. this is subject
    to change though.




## CUD'ing attributes after indexing existing lines

  - recall that the coarse parse state machine does the thing where it can
    characterize the type of line that the line is expected to be from only
    its first character. (‘\n’, ‘#’, ‘[’, `/^[a-zA-Z0-9]/` or whatever).

  - for those lines that are in the body of a document entity, *possibly*
    re-pseudo-parsing (in a non-DRY way!?) each line, we want it to be that
    each line is either:
    - a key-value pair (always one line)
    - a blank line (always just a newline)
    - a comment line (for now always flush left)




## CUD'ing and comment lines

  - this project is only the last in a proud tradition of projects like it
    where we take existing formats and use them as "datastores" such that
    they are simply human-readable plain text files that can be read
    _and edited_ by humans alongside machines.

  - for all projects like this, it's always a requirement that the human
    be able to use whitespace and comments in the expected way,
    _and the machine preserves_ the whitespace and comments when it edits
    the files. (consider how YAML or TOML is generally nicer for the human
    than JSON because the former support comments.)

  - but (informed by years of attempting things like this), in this project
    we provision tighter restrictions on the above general policy:
    *the machine won't create/update/delete a line that is "touching" a comment.*

  - our reasoning behind this new provision
    is left as an exercise to the reader ;)




## CREATE and comment lines

  - the line that a create will insert cannot end up touching a comment line.

  - if the boundary it's going to insert into has a comment touching it,
    (if it's the end boundary of the entity, add a blank line and append else)
    we will backtrack up along each contiguous comment line until the first
    non-comment line (or the top). if that "object" is a blank line, then the
    attribute will be inserted between the blank line and the comment line.
    this is best illlustrated with a test.

  - otherwise the CREATE fails with an explanation.




## DELETE and comment lines

  - an attribute line that is to be deleted cannot have a comment line
    immediately after it, immediately before it, nor can it have an
    in-line comment appended to it. there is no workaround. this fails with
    an explanation.

  - (relatedly, how we determine whether an attribute line has a comment
    on it is a whole thing we get into in [#866] a dedicated document on it.)




## UPDATE and comment lines

  - the exact same principle holds as for DELETE above.




## the practical implications of our comment behavior

  - they should be used when they make your life easier but note that
    the lines comments touch can no longer be machine edited.

  - to avoid this issue, have one blank line between blocks of comments
    and any attribute lines. if you do _this_, in turn, write the comment
    without assuming what the value of the (any) attribute being referred
    to. like, if you're talking about a particular value, include that value
    in the comment.




## creating attributes - overview

  - assume we already have an index of existing attributes (somehow).

  - use common, easy, lexical-esque insertion as we did with [#864]
    CUD'ing entities into/in/from documents.

  - whether "foo-bar" comes before or after "fo-obar" depends simply
    on the lexical value of the dash (whatever that is). we don't do any
    additional magic for this. we let the platform decide.

  - index these elements with case INSENSITVE indexing. it is not valid
    to have the "same" key with different casing. of "foo", "FOO" and "Foo"
    only one such casing can exist in a table. (:#here1)

  - (furthermore it may be the case that a name like "Foo" is invalid,
    whereas a name like "FOO-bar" is valid.)

  - for now we will extend the above idea to dashes but may change this
    later. for now, remove the dashes as part of producing a "gist" for
    a key. (more later, near "gist".)

  - no multiline values. (our hackish line-by-line parsng won't guarantee
    this but we'll try to get a "good-enough" level of certainty with this.
    we should at least do a validation pass after the edit to confirm that
    the set of names in the vendor-parsed dictionary is as expected, and that
    the any values that are strings contain none of a certain set/range of
    characters? not sure here. again maybe check for `"""` near #here4.)




## whole CUD pseudo-algorithm

we will support a whole macro all-in-one CUD operation
(an "EDIT" if you like)
that will allow you to specify any combination of CREATE, UPDATE and
DELETE attribute-level sub-operations where:

  - you can't do more than one operation on any one attribute key.
  - (intuitively) the keys under UPDATE and DELETE must already exist
    in the entity.
  - (perhaps intuitively) the keys under ADD must *not* already exist
    in the entity.

again intuitively, each ADD and/or UPDATE request component
will need a key and a value.
each DELETE request component will consist of a key only.

ultimately we will make this somehow atomic, like:

  1. lock the file for writing (or learn about semaphores).
  1. read & index the existing entity.
  1. validate (and/or index) the request against the document index.
  1. composite the new lines somehow. (this is the end of the heavy lifting.)
  1. rewrite the document to a temp file.
  1. move the temp file to clobber the original document.
  1. unlock the file or release the semaphore.




## sub-algorithm: the document entity index

for every line *after* the open table (section) line:

  - keep track of its offset (zero is the first line in the body of the
    document table).

  - determine which of the three types of line the current line is.
    this can fail.

  - if it looks like a key-value line,

      - sadly, offhand we can't think of a reliable way to ensure that
        the line doesn't begin a multiline value except checking for `"""`
        which we might do. and/or checking for the shorthand table thing..
        (:#here4)

      - ensure that the key is valid for whatever our restrictive rules are.
        this can fail.

      - make a "gist key" alla #here1.

      - ensure that no other key in the table thus far has a key with this
        same gist. we will need to maintain a dedicated dictionary for this
        in the index. this can fail.

      - for now, when we parse the key-value line, represent it as a
        "document line" object (make a class), which knows its line offset.
        we may go ahead and follow this pattern with a class taxonomy or
        composition thing.

now you have the "document entity index".

now iterate over every component of the macro request.

  - similar to above, validate the name used. this can fail.

  - similar to above, make a gist key of the name.

  - similar to above, if there is a key collision here (among other
    components of the request) fail & whine, i.e this can fail.

  - note we do not yet have a dictionary into which we put the gist.

  - each component is either a CREATE, UPDATE or DELETE. depending
    on some things this might need to be validated i.e this can fail.

  - if it's a CREATE,

    - a key with the same gist must *not* already exist in the document
      entity index. this can fail.
      (here especially it's important to explain this failure well:
      in the reason, distinguish whether the problem is that the keys
      are identical or if it's just that they look similar.)

    - this request component has a value associated with it.
      (so will UPDATE.)
      (below (at #here2) we'll discuss how values are validated/normalized.)

    - there's a whole thing for determining the insertion point
      below (at #here3).

  - if it's an UPDATE,

    - a key-value under the same gist must *yes* exist in the document
      entity index. this can fail, and similarly requires a full explanation.
      if the two keys are similar but not the same, again fail: we don't
      want to have to specify here whether the new capitalizaton/dashing
      should replace the existing or not.

    - like CREATE above this request component has a value,
      and will undergo normalization discussed below at #here2.

  - if it's a DELETE,

    - same as UPDATE, the key with the same gist must exist in the document
      entity and must be the same surface form. this can fail.

    - (unlike the others, this has no value associated with it (and cannot)).




## determining where to insert (for CREATE) is not straightforward

  - we don't have any kind of schema but one day we MIGHT.
    (this is now "future feature 3".)
    - (think DTD's from XML but like less obtuse somehow.)
    - (if you do this, do NOT put this metadata _in_ an entities file!
      it should probably be in parent directory of the parent directory
      of the file etc as far up as necessary to get out of the recursive,
      "elastic" (lol) tree.)
    - this schema could contain ordering information.
    - BUT at this moment we are NOT interested in developing such
      a schema; it sort of feels like a smell.

  - also, at this point we will _not_ require that the document attributes
    occur in alphabetical (or any particular) order.




## our requirements for determining the insertion point

  - requiring that attributes occur in a certain self-consistent order
    (although satisfying to our OCD) feels contrary to the whole spirit
    of formats like this.

  - as offered above, nor do we have a schema structure to dictate the
    ideal order (FOR NOW).

  - we don't want to like, penalize the document entity for its attributes
    not being in (say) lexical order. (more in the next section).

  - more to the point, the human might have aesthetic and/or practical
    reasons for ordering certain prominent attributes in a certain way
    (like wanting a `noun-phrase` attribute to the be the first thing,
    and `short-description` thing to be the second one. bad example..)

  - BUT having said all of the above, we want some behavior that's
    deterministic and unsurprising. this means platform lexical order.




## insertion proposal in lieu of an ordering schema (:#here3)

of the zero or more attribute lines in the document entity body
(hm we'll skip over blank lines and comments for now), find the longest
contiguous span of them _anchored to the end_ of the entity body that
are in lexical order (when reading the file in the normal way).

so like, if all the attributes are ordered with respect to each other,
then this (Case443):

     <--here
    A
    B
    C

if none of the attributes are ordered when anchored from the end,
then this:

    A
    B
    D
    E
     <--here
    C

if some of them are, then this (Case404):

    A
    B
    T
     <--here
    Q
    R
    S

for completeness, if there are no items, then this:

     <--here

the "here" demarcations above demarcate the beginning of the longest
contiguous run of items that are ordered with respect to each other _and_
anchored to the end.

THEN

you _could_ order your items to be inserted as like a stack where the
greatest lexical values are at the _top_, and walk backwards from the
end of the ordered run lookng for the right insertion offset..

keep in mind when you insert an item it will stale all the indexes
of all the items after it! we might do something more clever involving
several dictionaries (an `after` dict, a `before` dict,  and an `offset`
dict (or not)) to simulate something like a linked list..




## validating/normalizing values

TODO :#here2. we hate this. separately there's concerns for
validating/normalizing those values in request vs validating those
values present in the document. there's type-ism to worry about..




## full synthesis of pseudo algorithm

  - a request with zero components has undefined behavior. this can fail.

  - validate each component (described above) while grouping them
    like so: CREATEs in one group and UPDATEs and DELETEs in another.

  - just for determinism, in each group order the items lexically by key.

  - AXIOM (hard to prove): deleting things won't trip up the following.

  - for each component in the UPDATE/DELETE group (in its order),

    - retrieve the corresponding document line object (somehow).

    - (somehow) see if the any line object after it or the any line object
      before it is a comment.

    - (somehow) see if the line object itself has an in-line comment.

    - aggregate the up to three reasons into one emission structure,
      and emit it. i.e this can fail.

  - if you got this far, flush the zero or more UPDATE/DELETES into
    some kind of mutable structure that we are seeing as linked list-ish
    with two dictionaries.

  - against this modified structure,
    we will preview if we can do the inserts.

  - do the thing where we determine the longest contiguous run of ordered
    items anchored to the end (i guess use the modifed structure).

  - with this run of zero or more items, just iteratively insert each
    component from the CREATE group there, while doing so checking the
    comments thing (in this case just checking for whole-line comments
    not in-line comments.) we can short circuit fail out of any first
    incident we find.

if you get this far without failing, you should be able to produce a
stream of lines from your modified structure and with this stream of
lines use the UPDATE operation on existing files.

oh this just in: imagine using this "mutable structure" for a CREATE
of a whole entity. yeah that's a requirement too!

or even when it's the first entity in a file, using it to create the
file!




## in-depth code explanation

assume the attribute name of each request component is unique and that
the necessary in-document presence/absence of each key-value is checked.

derive an array of the line objects and for those that are attributes,
create a dictionary that produces a line offset given a gist.

with this "index", for each attribute that we are going to UPDATE or
DELETE, we can immediately get its line offset and from that, retrieve
the any line above and below it and see if those lines are comments.

whenever you change the tentative composition of the document entity you
should stale this index (rebuilding it when still needed) unless you
*really* know what you're doing! (more below.)

UPDATEs are distinct in that they never change the "comment signature"
of the document entity.

UPDATEs and DELETEs have identical validation here: no touching a comment
line above or below, and no in-line comment on the attribute line itself.

CREATEs are similar but not the same: similar to above, CREATEd lines
can't end up touching a comment line above or below; but here there is no
checking for in-line comments because there is no existing line.

also, for CREATEs it hurts the brain less to group contiguous CREATEs
together by insertion point and then only check the insertion points
one-by-one for comment contact, rather than validating each CREATE,
inserting it, then re-indexing the document entity after each such
tentative insertion.

we haven't verified that this is necessary, but it "feels like" it makes
sense that we should apply the would-be DELETEs first (provided they
pass their check) and then evaluate the any remaining UPDATEs and CREATEs
against the imagined document entity without those lines we would delete.

we suspect that in fact this is not a necessary precaution because a
DELETE will never create a new attribute-line/comment-line contact where
there was not one already (like, as part of the stated objectives of this
validation);

but regardless, it's hard to prove this suspicion and it makes the head
hurt less to err on the side of caution and follow this intuitive (if
wrong) assumption that we should partition the request components by verb
and do them in their own discete passes, in the order derived from this
analysis.




[link1]: https://github.com/toml-lang/toml




## (document-meta)

  - #born.
