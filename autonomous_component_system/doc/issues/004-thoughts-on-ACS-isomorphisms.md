# thoughts on ACS isomorphisms :[#004]

## the successful experiment :note-A

the below was a successful experiment in that it proved
the theory wrong: we cannot have named arguments that work with
platform defaults except in restrained cases. here was the original
objective:

    the objective is to implement the interpretation of named
    arguments in such a way that uses the real defaults in the
    signature while asserting the required parameters and
    integrating any one glob parameter.

    towards using real defaults we cannot merely place the values
    into a fixed-width array with holes left in it. rather we have
    to "skip over" an entry for `opt` params that were not passed.

    the syntax of the platform language dictates that these "real"
    defaults (`opt`) must always be contiguous with respect to one
    another; and if there is a `rest` param along with them, it
    must be placed immediately after them. but this "section" can
    occur in front of, behind, or in the middle of the zero or more
    `req` parameters.

    as such we do not assert that syntax here but assume it.

we had to get halfway thru implementing this to figure out that it
doesn't work and that's OK.

we disovered :note-A.2:

    once you start (effectively) requesting platform ("real")
    defaults by not passing an argument, you cannot stop using
    defaults and go back to explicitly passing values for these
    `opt` parameters because of a necessary asymmetry determined
    by the platform syntax (because platform arguments are not
    in fact named).

we came up with the term "opt-hopping" to help us understand this.




## today's compromize :note-B

this compromise still feels kind of nasty, but not as nasty as its
predecessor:

  • platform required's are required,
  • platform "optionals" are optional,
  • and globs are globs
    (we get the `zero_or_more` arity, not `one_or_more`)

this is the nasty part: a platform optional is optional because a
default was specified in its platform signature. to implement this
isomorphism here we disregard that default fully and always: rather,
when such an argument is not provided, we use a default that was
specified in our DSL (either specific to the one parameter or a default
default specified somehow specially).




## when to raise exceptions :note-C

it's the responsibility of the client to express validity in
its own modality appropriate way. if required parameters are
not passed at this low level it is deemed a failure at using
one's own internal API, and as such it is not appropriate to
emit an event. to raise an exception is useful for debugging.
_
