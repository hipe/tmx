# CLI table notes :[#050]

## scope of this document

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
the complex. however the current thinking is that with a "unified pipeline"
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



### new way vs. old way in a bit more detail.. :[#here.C]

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
to a string until it is actually rendered and immediately
produced as a streamed item.

exactly how we predict these value-as-string widths without
producing the strings is explained at #table-spot-2,
"a priori string width inference overview".




## finding the width of columns with floats :[#here.A]

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




## why the position systems are different.. [#here.B]

if you design a table that uses both field observers and summary
fields (we're looking at you, [cm]), it would be reasonable for
you to expect that the specifications for both would use the same
"position systems" (and indeed we took pains to make it so, only
to discover what we are about to say here).

"position system" simply refers to what the offsets mean when
offsets are used to refer to columns: are the the columns *before*
summary fields have been added, or after? the answer will
impact how we reference every column that occurs after any
summary field.

the solution we arrived at was counter to instinct: we use
"input offsets" when appropriate, and otherwise we use "field offsets".
our instinct was to avoid using two position systems in the same design
specifications, but it turns out there is a very real benefit to
doing so:

using both position systems is more poka-yoke: our pipeline is
hard-coded to be two-pass only. so you can only create a field observer
on an input field, not a derived field. using the position system of
input offsets enforces this idea, by disallowing you to refer to a
field that hasn't been "expanded" into the tuple yet.




## #internal-API-point :[#here.D]

in the internal "defined fields" array of "table design" instances,
a field with no metadata is only ever represented by `nil`, and `nil`
(in this context) only ever represented a field with no metadata.




## "the delicate art of custom formats" :[#here.E]

we assume that any given format always produces strings of the
same width (with respect to the particular format). (note this
is a fragile assumption; the onus is on the user to provide
formats appropriate for the range characteristics of the data
 #table-coverpoint-E-1.)

so because we have a format, if we discover the value-as-string
for this first (in page) value of this typeish, we assume that
the width of that string will be the same as the width of every
future string produced by every future same-typeish value in
this page of input against this same format.

as such: when we have custom formats we need not (and must not)
do the same kind of work that we do normally for floats. what we
do instead is this:

we format this first such value against the format just to get
the width of the value-as-string. we note this width and throw
away the string. the work of creating this same string is done
again redundantly in the second pass, but it is redundant only
for this first such cel in the page.

then, future occurrences of values of this type-ish in this
column in this page will effectively be a no-op. (but the
default statistical gathering our parent class does is still
effected, because somewehere we call `super`.) (or, we will
continue to gather some statistics on it of our own, we're
not sure.)

what happens here vis-a-vis integers will be a challenge..
we know what we want but not necessarily how best to get there.
(#table-coverpoint-E-2 we got there wickedly.)




## ever-widening vs. reclaiming width :[#here.F]

(additional relevant comments in code reference this tag.)

it's up for debate whether we want columns to be ever-widening
across pages, or whether we want to allow columns to shrink
back down to content (to "reclaim width") from page to page.

"ever-widening" will generally look better at first, because there
are less visible adjustments between pages generally. however
if the table ever gets "too wide" it never shrinks back down.

to restate the same from the opposite perspective, if we
"reclaim width" then the transitions between pages will generally
be choppier (because each page is rendered to fit only its
content); however we don't have the problem of an ever-growing
table.

presently the rendering pipeline is semi hard coded to effect
the "ever-widening" behavior model. there is a reader method
(on the design? on the invocation?) to indicate which model to
use, and if it were to be flipped to say to use the other model,
some parts might work (unfinished code sketch) but ultimately
it would almost certain melt down somewhere. longer term we would
like to support both.




## egads - :[#here.1]

in cases where we have summary fields (imagine fill fields) *and*
headers, we want our headers to report their widths to the field
surveys after that array has been expanded..

(the rest is in an inline comment.)




## (placeholder for unified language) :[#here.G]

(this would be for concepts outside the scope of [tab].)
(currently the start of something like this is in an asset file.)




## hotfixes :[#here.H]

  - there was a tiny bug :[#here.H.1]

  - changing widths (shrinking widths) hotfixes :[#here.H.2]



## the fill column API near a denominator term :[#here.2]

  - used to be just "denominator", now is a two-tuple..
  - for now, we want "min" and "max" but this is in flux



## nasty case of a "total" cel plus visualization [#here.I]

explanation is inline. :#table-coverpoint-I-1
