# fun with help screen parsing :[#054]

## intro

this tag both documents the subject asset node and tracks other similar
implementations elsewhere in this universe that do something like parse
help screens.

at writing we know of at least four:

  - born 2016-04-02 [#here.4]  was: zerk/test/non-interactive-cli/help-screens.rb

  - born 2015-07-07 [#063.2]   [our help screen scraper]

  - born 2013-11-15 [#here.2]  was: brazen/lib/skylab/brazen/cli/isomorphic-methods-client/models-/help-screen.rb

  - born 2013-09-21 [#here.1]  was: brazen/test/cli-support/expect-section.rb


despite this, this node was preserved during the sunsetting [hl] largely
because its state-machine-based implementation -- while being redundant
with both the aforementioned work *and* the [ba] state machine --
is small, lightweight, and relatively easy to understand even after all
this time. so we are carrying it with us as a memento of [hl] and
perhaps as a reference for future work.

note that our "syntax" may have changed - nowadays maybe we don't
require the use of colons to indicate all headers; a change in indent is
perhaps enough.




## (original, legacy but still relevant content)

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
