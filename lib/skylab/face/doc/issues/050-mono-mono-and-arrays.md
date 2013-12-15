# mono mono and arrays :[#050]

when parameter arity is [zero or ] one and argument arity is one, in cases
where we have an array as the argument, for now we are going to carp, because
with passive option parsing (the way it should be - don't throw exceptions
during the opt parse please), the optparse for now "upgrades" what should
have been one atomic argument to an array of all the arguments provided, even
though one is all that is accepted.

we originally wanted to let absolutely anything through including arrays, with
the thinking that it is a design choice of the particular API to accept an
"entire" array as an atomic argument to a monadic parameter with a monadic
argument artiy. however we will now see how this new strictness works out..

#experimental
