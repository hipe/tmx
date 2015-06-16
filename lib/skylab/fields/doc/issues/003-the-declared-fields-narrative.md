# the metahell fields narrative



## original introduction for posterity

this is now the center of metahell. these are the tools of metahell.
an extension node - know its implications [#046]. lots of touchers [#048]
abstracted from siblings, whence comes its coverage



## introduction to the new editon

at the time of this writing there are at least three field-like
implementations in [mh] alone, of which only one of them is reflected in
the [#053] "comprehensive"/historical list.



## an overview of the field libs in [mh]

1) originally "fun fields" (now [mh] "basic fields", not to be confused with
[ba] fields) was a non-extensible simple implementation that used a hash
to map a field's normalized name to its ivar.

the "absorber method" syntax of this DSL has grown to support a lot of the
features offered elsewhere (passive/active, glob/nonless) and some that
are not (supering). in the interest of self-reliance and regressibility,
this facet does not share implementation with the other field DSL's, although
the syntax is quite similar.

there is no support for any meta-characteristics at all whatsoever
(required fields and so on).


2) "contoured fields" started as a DSL to creat config-like structures
that are primarily composed of memoized values calculaated once
on-demadn. this may have been the first field-like DSL with a syntax.

3) "fields from methods" was next.

what is significant is that nodes 2 & 3 share an underlying "field box"
implementation.



## :#client-methods

contrary to our frenzy of writing "method touchers" everywhere, we use a
plain old extension module here. it is made public in anticipation of
the client module opting to include it earlier in its chain in order to
manage the inheritance chain.

when things were simpler the "method touching" pattern was adequate, but
now that they are more articulated we may see a future with methods that
were once touchers being moved here.

we give these methods verbose names, always with "iambic" in the name,
in order to avoid (but not prevent) name collisions with other libraries
and application implementations. but note that if there is a name
"collision", it had better do the same thing as the clobbered method,
given how verbose the name is.
