# "defined attribute" :[#002]

## document & node introduction :[#here.1]

the jump from the oldest section in this document to the second-oldest
(and the rest) is a span of many years. generally the subject tracking node
is about what we'll call the "defined attributes sub-sub-system", which is
a collection of related libraries built around assumptions discussed [#here.C].




## formal attributes vs. actual attributes :[#here.2]

(EDIT: very old)

What is the essence of all data in the universe? It starts from within. with
metaprogramming.

Let's take some arbitrary set of name-value pairs, say an
"age" / "sex" / "location" of "55" / "male" / "mom's basement"; let those be
called 'actual attributes'. You could then say that each pairing of that
attribute with that value, (e.g an "age of 35") is one "actual attribute"
with "age" e.g. being the "attribute name" and "35" being the
"attribute value."

Now, when dealing with attributes you might want to speak in terms of them in
the abstract -- not those actual values, but other occurences of particular
values for those attributes. We use the word "formal" to distinguish this
meaning, in contrast to "actual" attributes.

For example we might want to define 'formal attributes' that define some
superset of recognizable or allowable names (and possibly values) for the
actual attributes. For each such formal attribute, this library lets you
define one `Formal::Attribute` that will have metadata representing the
particular formal attribute.

To represent an associated set of such formal attributes, we use a
`Formal::Attribute::Box`, which is something like an ordered set of formal
attributes. Think of it as an overwrought method signature, or formal function
parameters, or a regular expression etc, or superset definition, or map-reduce
operation on all possible data etc wat. If the name "box" throws you off, just
read it as "collection" whenever you see it.

To dig down even deeper, this library also lets you (requires you maybe) to
stipulate the ways you define attributes themselves.

Those are called meta-attributes, and there is a box for those too..

So, in reverse, from the base: you make a box of meta-attributes. This
stipulates the allowable meta-attributes you can use when defining attributes.
With these you will then effectively define (usually per class) a box of
attributes, having been validated by those meta-attributes. Then when you have
object of one such class, it will itself have (actual) attributes.

(There is this whole other thing with hooks which is where it gets useful..)

To round out the terminology, the object that gets blessed with all the DSL
magic to create meta attributes and then attributes (and store them!) is known
as the "definer" (`Formal::Attribute::Definer`) which is what your class
should extend to tap in.

It may be confusing, but the library is pretty lightweight for what it does.
Remember this is metahell!




## pertinent ideas around "attributes actors" (and related) :[#here.C]

  - most association sets are specified simply with a hash:

    the association set definition has a surface form that is
    simply a hash whose each element has a value that is either
    `nil`, a simple symbol, or an array of symbols. (these symbols
    are the meta-associations.)

  - there is a fixed set of recognized "meta-associations."

  - you can specify arbitrary ("business-specific"), niladic
    ("flag"-like) meta-associations outside the fixed set by naming
    them with a leading underscore.

  - no dynamic [meta-]associations:

    contrary to [#012.J.3], we implement around specifically *not*
    supporting dynamic associations. (that is, collaborators must
    assume that associations are *not* determined at call-time.) thus
    we can allow ourselves to take an "indexing pass" if it helps the
    algorithm run more smoothly (hence the reason it makes sense to
    have an "association index", i.e the subject).

  - (however) static indexing has been removed:

    when we assimilated to "one ring", we refactored-out two
    static array passes (#tombstone-C). generally, "indexing" each
    association around one or another particular category was useful
    then, and is not now.

  - weirdness around how "required-ness" was/is specified and
    implemented is discussed at [#here.3].





## weirdness in how "required-ness" was/is specified and implemented :[#here.4]

TL;DR: parameter arity's default value is context-dependent, so if it's not
set explicitly on the association, you are no longer allowed to read it by
calling `parameter_arity`. the details:

for reasons that now seem arbitrary but that evolved from a desire
to keep our definitions concise while still being "intuitively" expressive;
there was/is strangeness in how "required-ness" was expressed and implemented
under the auspices of facility "C":

  - if every association in a definition set used neither the `optional`
    modifier nor modifiers that implied optionality (defaulting (and ??)),
    then this has the effect of every association being treated as optional
    (but note this was perhaps only under facility "C", as disucced below).

  - otherwise (and any one or more association either uses the `optional`
    modifier or modifiers that imply optionality), then the effect is
    semi-unsurprising: those associations that neither state `optional`
    explicitly nor imply it are required.

one "positive" design consequence of this is that a model with "many" (say,
five) associations in it didn't need to "clutter" its surface expression
by stating `optional` over and over again.

but this had problems:

  - there was no way to define an association set where every
    association was required.

  - the "spurious implementaton" problem hinted at above and described below.

  - in an effort intended to be parsimonious but that proved shortsighted,
    we posed defaultancy as implying optionality (and hence made their
    corresponding modifiers mutually exclusive to reinforce this).
    we now assert that [#012.E.1] defaulting must be allowed to fail,
    and so it again has meaning to say an association is both required and
    has a default. (in more detail, providing a default automatically
    implies that a thing is optional IFF the default value is passed
    explicitly in the association definition. whew!)

the "spurious implementaton" problem is this: in one location in the code,
we would default the association's `parameter_arity` to `one` (meaning
required), but in another location we would effect the behavior we describe
above, of only checking for missing requireds if one or more of them
classifies as optional (`attributes/defined-attribute.rb:233` and
`attributes/normalization.rb:457`, respectively, under #tombstone-A).

this alone is cause for concern, but what's worse is that what we were
afraid of happening happened: some normalization implementations cared
about only the first part (they checked for missing requireds againt whether
each association has a `parameter_arity` of `one`); and other
implementations honored the second part (i.e they effectively skipped a
missing requireds check when all are required); making for implementations
of normalization near required-ness that were globally inconsistent.

(this proved to be the nastiest part of assimilating facility "C" - issues
stemming from it cost at least a day.)

our fix for this (for now and for keeps, variously):

  - a function to determine requiredness of an association is a thing

  - as such, the lingua-franca is no longer streams but an
    an "association index" as discussed [#here.E] next.




## the new lingua-franca :[#here.E]

streams of associations ("attributes") used to serve as lingua-franca
between sidesystems: we would pass them between [ac], [ze], and it was
part of their public API so applications played along too. but then

  A) the yikes issue of [#here.4] was brought to our attention
     and so we wanted clients to be made aware of this through this
     explicit acknowledgement of it in our API.

  B) to make the passing of association collections happen via only
     streams of "native" associations like this, we realized it was a
     bit of a shoot in the foot because it's not extensible at all.

we call the subject class "cautious" because (perhaps as a hack, perhaps
not) this guy always reports an association as required if it was not
specified explicitly as anything (contrary to local convention).




## document-meta

  - :#tombstone-A (same as "#history-037.5.C" in "normalization") -
    the "FUN" methods and more "association index"-related, 1st pass
