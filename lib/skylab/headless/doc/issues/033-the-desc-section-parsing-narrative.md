# the desc parsing narrative :[#033]

`parse_sections` - the rules are simple: a line that consists of one
or more non-colons, and then terminated by a colon, that is a section
header. That may be followed by an item line which is a line that:
starts with one or more spaces, then any nonzero-length string
without two contiguous spaces in it, then two or more spaces, then the
first non-space and whatever comes after it. These two content-y parts
that were matched make up the item-line's header and body.
(Provisions may be made for an item-line either without a header or
without body). An item-line may be followed by an item sub-line, which
is any line immediately following an item-line or other sub-line that
has more indent than that last item-line. This pattern is not recursive
(there are no more levels of depth), and none of these need have
consistent indentation; it is only that the sub-lines have more
indentation than their host item line. Here is an e.g of the 4 kinds:

   bleep bloop              # 1) normal line (pretend it has no indent)
   ferpy derpy:             # 2) this is a section hdr b/c of the ':'
     nerpulous  ferpulous   # 3) item line b.c ' '+, "sentence", ' '{2}, ..
     bleep blop  blaugh     # 3) "bleep blop" is header, rest is body
       shim sham flam       # 4) item sub-line b.c more indent than 3
     [<path> [..]]  bazzle  # 3) something like this was the insp.

Tabs would be trivial to add support for but they make the regexen
look really ugly so just don't use them. You just can't have them.

This algorithm is infallbile and it cannot fail.
