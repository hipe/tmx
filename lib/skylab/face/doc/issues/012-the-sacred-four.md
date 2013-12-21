(EDIT: this is historical. what is described below is very likely no longer
good or OK. we will one day use this marker :[#012] as a guide to locate
and refactor code away from this model. self inflicted pain is the most
unforgettable kind. (actually we may bend this into a different concern,
that of business vs. operational fields..)

# the sacred four :[#012]

..refers to four parameters we often pass to entity-library (usually
controller) methods. they are (in this order):

1) "fields"
2) "options"
3) "if_ok"
4) "if_not_ok"

the first two are usually (but not necessarily) hashes and the last
two are callbacks. beyond that the details of the "spec" remain sketchy.

## justification

### the input parameters are perfect

One nice thing about the input parameters is that they are wide open,
and the downstream receiver can validate (or not validate) their
composition as deemed appropriate. This allows us to future-proof these
method signatures while still acting with integrity today.

Another thing about the input parameters is that there are two of them:
we almost always have exactly these two namespaces for incoming
parameters, and should never need more, and cannot survive with less:

There are two hashes because there are two domains: the app and the
framework. as the frameowrk (or just library) we get to define meaning
for the options, and well as any structure grammar.

On the app side, however, we as the framework *must* not assign special
meaning to the business-level fields' name or composition, duh.

### the output parameters are perfect

One nice thing about the output parameters is that if we follow the
convention, the user always knows what the end result is of the
method call - it is the result of the callback.

(they should almost certainly be mutually exclusive and monadic -
that is, of the two functions, to total number of times that
either of them is called should probably always be exactly one.)

the binary "yes" / "no" duality of the last two callbacks is something
that occurs in nature as well as science.

two is the first non-one positive integer, and four is the only number
that can be reached by the same number adding itself to itself or
multiplying itself by itself; so in this sense, four is a number whose
degree of self-reflected-ness inside of it makes it perfect for this
library.


EDIT: (the below is from `pack_fields_and_options`, ancestor of
`unpack_field_values`. and still seems somewhat relevant but not there.)

experimentally many methods in the entity library take the "sacred four"
parameters [#012]. freqently requests coming in from the client will munge
the two namespaces (one of business-level fields, (e.g "email") and the other
of controller-level options (e.g `verbose`), however the entity library
insists on more rigidity and structure than this.

experimentally your API actions defines parameters (a.k.a fields) using
meta-fields that tag meta-info about each field, e.g whether the field is a
"field" field or an "option" field.

So, of each field in this field box reflector, along the categories of:
  `field` and `option`,
when each field falls into one (or more wtf) of these two categories one hash
is made for each category, with its names being the field name and its values
being the field's values. result is always an array of two hashes.
