# using the node table :[#002]

## objective

this document describes how the [node table](../README.md#node-table) is used.




## overview

  - the "node table" keeps track of identifiers that look like
    [#001], [#002] (etc) used in this project.

  - the primary purpose of the node table is to keep track of which
    identifiers have been allocated, so that we know which ones are
    still available.

  - node identifiers can be used to track documents in the project. we use a
    number and not names as a _concrete_ way to reference a document, because
    a document's name will often change over time, while the number can
    remain constant thru name changes.

  - (when referencing a document, you should use both its identifier number
    _and_ a descriptive name after the document, unless you're _really_
    pressed for space.)

  - node identifiers can be used to track "issues" (like bugs or planned
    features or wishlist items). we don't generally call these things "nodes".
    when the node tracks an issue we just call it an "issue" not a "node".

  - nodes can have arbitary tags associated with them, exactly as tweets
    have hastags (but experimentally a tag name can use single dashes as
    word separators). nodes that track open issues will have the tag `#open`
    associated with them, typically in the "Main Tag" column of the table.

  - occasionally we will associate a node (number) with a particular .. er ..
    node of code; with the same justification offered about documents above -
    that it's a concise way to reference something in a manner that
    endures name changes (which are frequent in code).

  - when we do so we will typically associate the identifer with a
    particular class or module (but not, say, a method. we just use
    the name of the method or function and change its name as necessary).
    we typically avoid more than one identifier per file, but rather
    opt for [sub-identifiers](#sub-identifiers) (explained next).




## sub-identifiers <a name="sub-identifiers"></a>

  - they look like this: [#001.A]

  - sub-identifers are usually used to identify sections in documents,
    when necessary.

  - but sub-identifiers could be used to identify a bunch of small,
    related issues that need fixing.

  - [#001.a], [#001.b] etc for sub-identifiers that don't leave the document.
    (when we want to refer to one point within a document from another point
    within the *same* document we sometimes use `#here1`, `#here2` etc.)

  - [#001.A], [#001.B] etc for sub-identifiers that don't leave the project.

  - [#001.1], [#001.2] etc for sub-identifiers that do. (think "public API"
    from [semver.org](semver.org])).

  - more than 26 is too many sub-identifiers for a document anyway.

  - **sub**-sub-identifiers have happened in the past, but eew. we just use
    numbers for sub-sub-identifiers, but (again) eew.

  - we may opt for semantic anchor names rather than this system, when
    dealing with documents (because single-letter anchor tag names look
    weird and sorta feel wrong).



## reallocation

(brief sketch)
  - like numbers in the NBA
  - philosophy
  - we've never surpassed 200




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

  - #born.
