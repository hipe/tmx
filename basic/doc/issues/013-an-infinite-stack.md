# meta-fields - an infinite stack

a note on implementing with metafields - we have an algorithm in our
head that actually could handle an infinite stack of meta fields
(meta-meta-meta-meta fields and so on): each time you pop one frame
down of meta you produce the field class that will be used for each
element of the next frame.

each previous frame defines the set of allowable elements for the next
frame and that's really all there is to it.

## example

the current working model looks something like this (pseudo code):

    meta-meta-meta-fields: :property

    meta-fields: :required, :list, [ :regex, :property ]

    fields: [ :first_name, :required ], [ :last_name, :regex, /foo/ ]

(it really only can make any sense if you start from the bottom
and understand that, and then work your way up. if you don't understand
the higher two levels above curently, don't worry.)




## analysis

The general truth about "n-meta-fields" statments like above is:
they always receive as an argument one (globbed) list (array) of
tuples. each tuple may consist of a single symbol in which case it
may be expressed as the symbol alone, not in an array.

tentatively, with the working model, each element of the tuple must
be a symbol, except for properties, which we'll get into below...




## justification

We don't think it's totally absurd and un-reasonable that developer
clients of this library work with the last two levels - meta-fields
and fields, for they unleash a lot of power when defining logic at
these two levels of meta.

(e.g let's say you suddendly realize that in your system, a subset
of all the "fields" (logical, conceptual, whatever) in your system
need to support unicode. .. etc)

these first two levels of meta fit squarely in the business domain
of the app, at albeit a somewhat low-level.

more on this when we need it ..
