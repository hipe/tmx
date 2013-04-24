# the sacred four

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

### the output parameters are prefect

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
