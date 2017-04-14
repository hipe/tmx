# entity collection via git config :[#028]

## in context

(EDIT when better integrated)

the subject library is a bit of a solution in search of a problem; but
it's one we feel strongly about maintaining.

something something #feature-island.

it's worth explaining how it arrived at its current form:

at one point we used the facilities behind the subject library to
store and retrieve an entity that consisted of a single, "primitive" value.





## a universal normal name convention :[#here.B]

the git config syntax specifies that variable names cannot contain
underscores (but dashes are OK). however everyplace else we usually
follow the opposite for "normal names" ("normal names" have underscores,
the things with dashes we call "slugs"). (but yes, we like the look of
"slugs" better so we are glad git adopted this as the standard).

hence we are left with conversion work to do: going into and coming out
of the collection we need to convert dashes to underscores in field
names. furthermore we haven't yet said anything about all the other kinds
of characters, like numbers, mixed case names and others.

as it stands this is work left for the client to do; the collection
merely borks with a message when invalid names are passed. and this is
halfway to the way it should be: if the collection makes decisions about
how to convert invalid names to valid ones, information may be lost,
which is tautologically the wrong way for a collection to behave:

    `foo-bar_baz`   ->   `foo-bar-baz`    ->   `foo_bar_baz`

   contrived name        collection name        incorrect guess


a better way might be to agree in one place universally on a set of
rules dicating "univerally normal names": it would be a super distilled,
lowest-common-denominator standard, something like:

    /\A[a-z][a-z0-9]*(?:_[a-z0-9]+)*\z/

that is: alphanumeric, all lowercase, underscores only used as
separators (so no leading or trailing underscores and no underscores
occuring in multiples adjacently).

(we *might* allow case-sensitive capitalization to sneak in, which we
might then shoehorn into this term of `variegated_symbol` that
we've been using.)

if both the business layer and the collection know that this is the
standard, *and* the character classes variously that the standard speaks
of either *are* or *are not* allowed in the collection and in the cases
where they are *not* there are other characters available to substitute;
characters not included in the standard (whew), THEN it might be that
the collection can do the name conversions, rather than the business
layer having to worry about it, which would be optimal.
