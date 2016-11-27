# CLI table notes :[#050]

## scope of this documet

the official toolkit for tables is [tab] and so the central document
for modality-agnostic tablism is [#tab-001]. what is here is only for
those features of tables that are CLI-specific.




## history of this document

it bears mentioning that this document was created only during
"unification", years (and years) after the original table code was
written; so some (most?) of the ideas here are as ancient as the libraries
that are being unified at this writing.

the body copy, however, is all contemporary with this document. so maybe
it's possible for an idea to be both old and new.




## "justification of the new way"

during unification we merged the experimental (and expensive-feeling)
mechanism of "type inference" (and column statistics) with the more
mundane, ordinary "rendering pipeline" of the simplest of aligned tables.

on first analysis this felt cavalier to predicate the simple on top of
the complex. hoewver, the current thinking is that with a "unified pipeline"
everything makes the most sense, and the cost is the lowest it's ever been
to still have all these features.

a review of the old way can gain us a better understanding of the new way,
in terms of both its requirements and (by contrast to the old way) its
simplicity.

as an overview: the old way was probably triple-pass, and there was some
sort of conversion to string *twice* per cel. the new way is only dual-pass
(all table rendering with dynamic column width to a horizontal line-oriented
context requires at least two passes), and values are converted to strings
at most once per cel. but in detail:



### new way vs. old way in a bit more detail..

we arrive at a pre-calculation of how much width particular
values will need as strings without actually converting them
to strings, through a technique we call "a priori inference"
explained in detail in the code at #table-spot-2.

this technique replaces an older technique that had a higher
cost of memory and processing: in the old way we would in one
pass traverse the whole page converting each value to string
"early", and by noting the width of each value-as-string we
would determine what is the widest of these strings. then after
this maximum is found we would "flush" the matrix for a final
pass, converting these values-as-strings (somehow) to space-
padded strings in a final rendering pass.

this technique required that we store that whole matrix (page)
of values-as-strings in memory while we gathered the maximum
widths for use in generating cel-renderers for a final pass,
which is now seen as unnecessarily wasteful. (imagine a large
matrix of booleans or floats, for example, all being stored
in memory as strings.)

in the new technique this intermediate storage of strings is
avoided - the matrix is instead one of "typified mixed values",
where all we store in the matrix is the value tupled with a
symbol about its type. because we can predict (or, to the extent
that we can predict) the width of the content string before we
actually make the string, the value is never actually converted
to to a string until it is actually rendered and immediately
produced as a streamed item.




## finding the width of columsn with floats :[#here.A]

for any column that contains more than one float, it is NOT the
case that we can achieve the correct "widening" merely by
finding the max value-as-string of the cels (which is the
approach we take for perhaps every other type-ish of cel).

imagine 1.11 and 22.2: each of these values reports (correctly)
that its value-as-string width is 4. however, when you stack
them atop each other:

   -----
    1.11
   22.2
   -----

..the necessary width is actually 5. this is because we line
up on the decimal, and so those digits to the left and right
of the decimal place (individually) form their own little
columns of sorts.

here's a more pronounced example: 1234.5 and 1.2345. each of
those has a value-as-string width of (counting) six. but if
we render them "correctly" atop each other:

    ---------
    1234.5
       1.2345
    ---------

we actually need *nine* spaces of width.

so the "correct" way to find the necessary width for such a
column is to find the widest width ever of the two parts
*individually* (the widest of the left and the widest of the
right), and then sum them (plus one for the decimal character).

(the field survey logic is supposed to add one for the negative
sign so we don't have to deal with it here.) whew!




## why the position systems are different.. [#050.B]

if you design a table that uses both field observers and summary
fields (we're looking at you, [cm]), it would be reasonable for
you to expect that the specifications for both would use the same
"position systems" (and indeed we took pains to make it so, only
to discover what we are about to say here).

"position system" simply refers to what the offsets mean when
offsets are used to refer to columns: are the the columns *before*
summary fields have been added, or after? because the answer will
impact how we reference every column that occurrs after any
summary field.

but alas, (EDIT)

given this, it's more poka-yoke (EDIT)
