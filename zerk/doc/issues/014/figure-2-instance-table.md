# instance table

synopsis: some of the edges in the sibling graph are marked with tags
like `t1`, `t2` etc. such a tagging indictates that that arc represents
a "significant path"; one that (for some reason) we believe is important
to test.

the below table tracks whether and where each such path is covered.

see the counterpart table under [#012] for a deeper description of what
this is and how it is used.

this whole file hypothetically should probably not be in version
control because the below could hypothetically generated. but meh.

|     | file |  recap
| #t1 |  A   | no args at all
| #t2 |  A   | dash before any operation
| #t3 |  A   | unrecognized plain token
| #t4 |  A   | token points to an association (e.g) that is non-modal
| #t5 |   B  | loop back around to try and push another
| #t6 |   B  | ended input right after a compound
| #t7 |   B  | you can't have options right after a compound
| #t8 |  A   | o.p built, options didn't parse OK per o.p OR component
| #t9 |  A   | o.p built, afer parsed OK, you have remaining args
| #10 |  A   | there are missing required args
| #11 |  AB  | wahoo! you got a bound call
