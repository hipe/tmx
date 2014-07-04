# about globbing :[#009]

the general syntax of the "test/all" utility is something like:

    ./test/all [ <cmd> [ <subproduct-locator> [ <subproduct-locator [..]]]]

where <subproduct-locator> is used either to represent the complete
string name of the desired subproduct, or it is just a slice of the
name anchored to the beginning of the name (that is, the <subproduct-locator>
can be just the first few letters of the name of the desired subproduct).

so a subproduct locator of "fu" would match the subproduct named "fuxx" *and*
the subproduct named "fuh" (as well as the exact match of the subproduct
named "fu").

this started as a convenience to save on typing, but once we had one
subproduct named "git" and another one named "git-viz", there came the
problem that a subproduct locator of "git" would not exact-match just
"git" alone - it also would pull in "git-viz", even if that was not the
desired behavior.

our fix for this is a bit of a hack: fortunately our filesystem (or
whatever) sends us the subproduct names in lexical order, so "git-viz"
comes after "git". only because of this, we can use a hash (or "set") to
"tick-off" those exact matches that we don't want to use for subsequent
fuzzy matches.

meh
