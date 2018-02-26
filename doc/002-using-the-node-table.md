# using the node table

## objective

this document describes how the [node table](../README.md#node-table) is used.




## overview

  - the "node table" keeps track of identifiers that look like
    [#001], [#002] (etc) used in this project.

  - the primary purpose of the node table is to keep track of which
    identifiers have been allocated, so that we know which ones are
    still available.

  - node identifiers can be used to track <a name='b.3'></a>documents in the project. we use
    numbers and not names as a _concrete_ way to reference a document, because
    a document's name will often change over time, while the number can
    remain constant thru name changes.

  - (when referencing a document, you should use both its identifier number
    _and_ a descriptive name after the document, unless you're really
    pressed for space.)

  - node identifiers can be used to track "issues" (like bugs or planned
    features or wishlist items). we don't generally call these things "nodes".
    when the node tracks an issue we just call it an "issue" not a "node".
    (see also [\[#004\]](../README.md#004) the TODO stack, which is
    generally for smaller, more near-term goals; but can be used in
    conjunction with the node table.)

  - nodes can have arbitary tags associated with them, exactly as tweets
    have hashtags (but experimentally a tag name can use single dashes as
    word separators `#like-this`). nodes that track open issues will have the tag `#open`
    associated with them, typically in the "Main Tag" column of the table.

  - occasionally we associate a node (number) with a particular .. er ..
    node of code; with the same justification offered about documents [above](#b.3) -
    that it's a concise way to reference something in a manner that
    endures name changes (which are frequent in code).

  - when we do so we will typically associate the identifer with a
    particular class or module (but not, say, a method. to refer to a
    method, we typically just refer to it by name and change its name
    as necesssary).
    we typically avoid more than one identifier per file, but rather
    opt for [sub-identifiers](#sub-identifiers) (explained next).




## <a name="sub-identifiers"></a>sub-identifiers

  - they look like an identifer whose number component is followed by
    a dot and something else (like this: `[#001.A]`)

  - sub-identifers usually identify sections in documents.

  - sub-identifiers might also be used to identify a bunch of small,
    related issues that need fixing.

  - for this one pattern of sub-identifers, we use either an uppercase
    letter, a lowercase letter, or an integer; with the following
    semantics:

  - `[#001.a]`, `[#001.b]` etc for sub-identifiers that don't leave the
     document (but see [the next section](#d)).

  - `[#001.A]`, `[#001.B]` etc for sub-identifiers that don't leave the project.

  - `[#001.1]`, `[#001.2]` etc for sub-identifiers that do. (think "public API"
    from [semver.org](http://semver.org)).

  - more than 26 is too many sub-identifiers for a document anyway.

  - **sub**-sub-identifiers have happened in the past, but eew. we just use
    numbers for sub-sub-identifiers, but (again) eew.

  - we may opt for semantic anchor names rather than this system, when
    dealing with documents (because single-letter anchor tag names look
    weird and sorta feel wrong).




## <a name=d></a>file-local references

### _and other emerging conventions_

the conventions described [above](#sub-identifiers) glossed over some
points.

  - if the document is a markdown document (as opposed to a code file),
    we might be trending away from the number/single-letter sub-identifiers.
    instead we may be trending towards utilizing github-flavored markdown
    more fully by using html anchor tags with name attributes (more
    semantically named)

  - for now we will continue using a combination of both. for example,
    at writing the section we are in now has a single-letter name for
    its sub-identifier (`#d`); however the previous section uses a fuller,
    semantic (i.e meaningful) name (`#sub-identifiers`).

  - if you're in a code file and you want to refer to one point in the
    file from another point within the *same* file (but you don't want to
    promote the reference to a level of visibility outside the file), we
    use `#here1`, `#here2`, etc.

  - if you see `:#here1` (with the leading colon), that means that is where
    the thing is defined, as opposed to it just being referred to.
    (you can sometimes find where toplevel identifiers are defined in
    this way too, by searching for (e.g) `:[#001]`, etc.)




## reallocation

(brief sketch)
  - like numbers in the NBA
  - philosophy
  - we've never surpassed 200
  - vaguely like python's PEP, and vaguely the opposite too




## experiments

all of the ideas above have evolved and have been time-tested across
dozens of projects for almost ten years. however for this project we bring
a few new points of experimentation (in the spirit of continuing evolution),
with one design objective:

  - allow that our node table (our issues, mainly) render usably in
    the github-generated HTML of our README.

what follows from this are some would-be corollaries (design consequences):

  - our nodes will look most attractive and sane in a table.
    (while tables are not supported by original markdown, we are
    fortunate that github has extended markdown in this manner.)

  - we don't have to but we might as well just put the issues in
    the README.md in its own section (right?).

  - negative consequence: in the old format we could take up many lines.
    (but maybe it's more poka-yoke this way.)

  - negative consequence: making html anchors looks so ugly




## (document-meta)

  - this document can be referenced with `:[#002]` (without the colon)
  - #born.
