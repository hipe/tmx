# thoughts on ACS isomorphisms :[#004]

## the successful experiment :no-defaults

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




## when to raise :#exceptions




for present applications of this library at least and perhaps in
general, in error cases it is more useful for "an API call" to raise
an exception rather than emit an emission for the straightforward reason
that they are easier to trace. (the user of any API is (eponymously) the
*programmer*, and stack traces contain a level of detail appropriate for
such an audience.)

code locations tagged with the subject tag may also be towards realizing
[#006.C.2] "the cold eventmodel" as the universal rule as opposed to just the
norm..
_
