---
title: "the hack for determining inline comments"
date: 2019-01-30T17:59:00-05:00
---

our broad provisions 1, 2 _and_ 3 ([#864] "toml adaptation") hold that

  - we can enjoy the dependency-freedom, ease-of-use, and joy of
    human-editable plain text files as a datastore, while
  - using a format that is a subset of something well-known and
    widely supported

_provided that_ our format follows certain restrictions that make
it straighforward to parse coarsely.

then in in [#865] we discover why it's important for one particular
sub-algorithm to be able to determine if an attribute line has has a
comment _on_ it (so, on its right half). (we'll call this an "in-line
comment".) recall that the reason we disallow the editing of such lines
is _not_ technical.

>why don't you just check if '#' occurs anywhere on the line

as it would work out, this one weird requirement of being able to detect
attribute lines with in-line comments is perhaps the biggest monkey-wrench
thrown into an otherwise smooth-sailing piece of cake.

what it amounts to is that we have a problem with apparently no pretty
solution if all these are true:

  - we must detect if an attribute line has an in-line comment.
  - we aren't going to write our own full-blown, correct parser (YET)
  - notwithstanding we hold ourselves to attribute values being on one
    "surface line" (reconsider the other points with our without this point)

why this is such a challenge is left partly as an exercise to the reader;
but the short of it is: when most parsers parse things they ignore whitespace
and comments, which are surface phenomena whose very existence is tied into
them not being treated as data.

simply detecting for the presence of '#' would fall over for values like:

    color = "#75303D"

we ask a lot of the user, but telling them they can't have values like this
is a bridge too far.

on the flip side, imagine that we try to parse attribute values on our
own in some coarse way, following the rubric of our broad provisions.
well, from the toml [doc][link1]:

> Values must be of the following types:
> String, Integer, Float, Boolean, Datetime, Array, or Inline Table.

let's just say we're only trying to parse ("by hand") integers and floats.
have a look over at that link and look at all the examples of different number
formats that are supported and ask yourself if it's really a valuable use of
our codespace to try and parse all that redundantly for our own weird purposes.

SO here's our rough draft of what we're going to attempt:

  - for any existing entity whose attributes you are going to CUD,
    you will need to parse that table (or just its body) as a toml "document"
    (meaning don't actually parse the whole document, just the table).
    (you could even just parse only the "body lines" of the table.)

  - at this writing we have the ability to map attribute lines to the
    values of this parsed table (on the current platform, it's a dictionary)
    in a way that will sound awkward to describe here but is straightforward.
    so for any "attribute line" in our native "mutable document entity" object,
    we can straightforwardly see what the platform (python) value is.

  - (there are certainly edge cases where the above is not true; like where
    our hacky parsing lets through incorrect toml that will not parse (i.e
    _not_ toml). (for example, if the value surface form in our document is
    (#edit [#866.B] this changed)
    some arbitrary bareword like "foo"..) also #multi-line strings...)

  - indeed if the set of names from our "mutable document entity"
    _does not match exactly_ that set of names from the vendor-parsed
    structure, then this can fail.

(the above points will all be re-stated in some form below..)

we can copy-paste the lines directly from the toml spec-ish to here and make
this table and see how the toml types translate to our platform types.

(here we're using python but imagine a similar approach to whatever the
target platform happens to be.)

| toml type | platform type |
|---|---|
| String | `<class 'str'>` |
| Integer | `<class 'int'>` |
| Float | `<class 'float'>` |
| Boolean | `<class 'bool'>` |
| Datetime | `<class 'datetime.datetime'>`|
| Array | `<class 'list'>` |
| Inline Table | `<class 'toml._get_empty_inline_table.<locals>.DynamicInlineTableDict'>` |

(the above was created by copy-pasting example values from the toml
documentation page into a little toml document and loading it and looking at
the types as reported by python. that last one's a thing for later.)

recall the suggested hack above,

>does the line contain a '#'?

despite what we said above, now that we know with some assurance the
_type_ of the attribute value (in both contexts), we can _probably_ apply
this hack semi-safely depending on the type of value.

that is, the crudest version the algorithm ("does the line contain a '#'?")
is _probably_ correct for attributes with the types marked "easy" below:


| toml type | easy? |
|---|---|
| String | hard |
| Integer | easy |
| Float | easy |
| Boolean | easy |
| Datetime | easy |
| Array | hard |
| Inline Table | hard |


this leaves us with:

| toml type | easy? |
|---|---|
| String | hard |
| Array | hard |
| Inline Table | hard |

(begin rambling)

(side note, it seems like an inline table _must be_ on one line but an
array can be broken up across lines..)

(an awful way to determine if the array is multi-line is to re-parse it
given only the one line and see if you get the same (or any valid) result.)

(when you know the array or inline table is all on one line, if you don't
see a '#' on that line you know there is no comment, but the presence of
that character does not necessarily signify a comment's presence!)

(anyway, CUD'ing an attribute that is {Array|Inline Table} should be out
of scope/disallowed for now anyway, because it's a non-recursion recursion
that would require a whole bunch of new specification and like GraphQL crap.
like, how would you want a UPDATE to work from a CLI for such an attribute?
ok so how do you want a CREATE to work then? how is the storage engine to
know that you intend the string to be interpreted as a table and not a
string? it's a violation of the early provisions probably. maybe later.)

(we can peg this on the possible future feature of "schema": if you know
that the formal type of the attribute is one of these compound types,
then you can parse incoming string values accordingly (sidestepping any
GraphQL craziness).. these two types are now pegged on to that possible
future feature.)

(like with comments, the human can hand-edit their documents to have these
compound values; we just aren't gonna support machine editing of them for
now..)


this leaves us with:

| toml type | easy? |
|---|---|
| String | hard |




## ok, so what about strings is hard?

for one thing, there's four kinds:

  - basic (`"`)
  - multi-line basic (`"""`)
  - literal (`'`)
  - multi-line literal (`'''`)

see the doc, but our quick summary of these is: with literal strings there
is no escaping whatsoever, and with basic strings there is escaping in a
manner that will be mostly unsurprising to most programmers.

the way we could determine that the below doesn't have a comment

    color = "#75303D"

is to walk along the _surface representation_ of the value character by
character. (assume we know it's a string of some kind). (assume further
that we have a "cursor" that's advanced to the start of the surface
representation of the value.

we can determine the type of string wth a regex something like:

    rx = re.compile(r'(""")|(")' r"|(''')|(')")

(this one happens to be more readable in ruby for reasons:)

    rx = /(""")|(")|(''')|(')/

ok, we just read the toml doc in some more detail, and we got some
regexes defined with unicode ranges that seem to work. maybe this won't
be *that* bad..




## very rough pseudocode algorithm of the big picture.

givens:

  - \#edit [#866.B] change all this

  - assume you have some N lines (possibly zero) of the _body_ of your
    document entity (table).

  - assume that for each line that is an attribute line, we have the
    tail-anchored substring that constitutes everything after the
    equals sign (and one (for now) requisite space character).

  - \#multi-line strings will complicate this. for now, imagine
    they are not supported.

now, parsing this in python is _very_ short and easy with the toml library
that ships with python but this can fail (because we do only a crude pass,
we could have let incorrect toml (so, not toml) get this far.) (like strange
bare-words)

here's another fun one: it's possible to _trick_ coarse parsing into
interpreting a valid toml document in the wrong way. i.e this can fail
and we detect this by comparing the set of attribute (key) names.

(it seems like the reverse might be possible, where the vendor parse
detects elements that the coarse parse didn't. but we don't know how
to trigger that yet.)

if you've made it this far then you have one real value in your platform's
runtime for every attribute object (they are two-way isomorphic-ish).

*now*: remember the goal was to be able to determine whether there's
an inline comment on the attribute line. looking back at [#865], we see
that this will only be needed when the verb is UPDATE or DELETE on the
attribute. that is, edit requests are these compound things that can
operate on many attributes; but this in-line comment check is something
we only do to those attributes we're doing these verbs on.

as such this is not a check we need to do to every attribute in the
document entity, and because it could get expensive, it's work we will
avoid when we can.

furthermore we need not cache this work (for now). the algorithm is written
such that we need only ever make this check once for any attribute.

[so we do the by-hand parsing with a string scanner or the like.]




[link1]: https://github.com/toml-lang/toml




## (document-meta)

  - #born.
