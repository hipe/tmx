---
title: "multi-line strings"
date: 2019-05-06T20:44:30-05:00
---

## FREEFORM DISCUSSION

This discussion concerns only strings.

The retrieval of a string must of course be byte-for-byte faithful with
what was stored.

(We will ignore the question of whether we mean multi-byte character
encodings or not, for now.)

There can be variation in the "surface forms" that all express the same
"deep form" of a string.

In keeping with the founding spirit of this project (specifically
"broad provision 1"),
we want the data files to be human-readable (for our sense of).
A corollary of this is that
we don't want the stored expressions to run "wide".

Let's consider the prospect of supporting arbitrary strings. Assume it's a
given that the "surface form" is one of the [two kinds][A]
of multi-line strings in toml.
Several facets come to mind, in no particular order:

  - If the string contains `"""` or `'''`, it will need special handling
    as appropriate.
  - There is some "reasonable limit" we are going to want to put on the
    strings, because storing strings of some certain large size A) would
    violate our above cited principle of wanting the storage files to be
    readable and B) if we absolutely had to we could use the 'meta'
    attribute space and store the string in a byte-per-byte file.
  - There is perhaps also some "reasonable limit" on the small side of
    strings, for when it is appropriate to use a plain-old literal or basic
    string instead of their multi-line counterparts.

.#edit [#872.B] the unit tests don't yet cover wat do when a string is too large
(too many lines), but it should. then this should be true:

For more detail on this, the associated unit tests for the string encoder
are the authoritative source on what these self-imposed limits are.




## why we implement string encoding (escaping) ourselves

`toml.dumps` won't surface a multi-line string for us.

Rather, when we give it a very long string it will just surface a very long,
(single line, basic) string.

Very long strings (that run over, say, the 80 columns of a vt-100 terminal
from the 1970's that surely we will be using); these would be in conflict
with our aforementioned core principle of having our storage be reasonably
human-readable.

We cannot simply decline to support longish/multi-line strings because they
are part of our target use cases.

As such, in order to produce multi-line strings at all, we actually must
manage our string encoding ourselves. Doing so also allows us fine-grained
control over failure behavior when we encounter strings that fall outside
of our self-imposed limits.

So how do we implement our own encoding?
Start with these statements from the toml specification:

    those [characters] that must be escaped: quotation mark, backslash,
    and the control characters (U+0000 to U+001F, U+007F).

    For convenience, some popular characters have a compact escape sequence.
    [9 sequences or types of escape]

We "inner join" this set of characters against a wikipedia table of unicode
characters (low ones) to get the "table" in code that references this section.

This table has (in effect) 4 columns: the first column (actually the key)
is the decimal integer of the character; the first "field" is the "name"
(from wikipedia) for the character, the second field is yes/no whether we
support the storage of this character, and the final field is the character
we use in the escaped expression (if we support it).




[A]: https://github.com/toml-lang/toml#string

## (document-meta)

  - #born.
