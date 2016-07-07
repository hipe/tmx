# contextualization :[#043]

## historical context

this does or will represent the distillation and unification of
around *5* (*five*) or more related efforts, spanning at least 4
years of development.

we say that to indicate its breadth of applicability but not its
depth of code -- these individual implementations of
"contextualization" each had only around 50 lines of code or so.





## intro & overview of interface

this is a session that assists in expressing emissions, mostly in terms
of inflecting them based on their structural characteristics.

  • it has a [#fi-007] session interface.

  • it is [#sl-023] dup-mutate compatible.

in one form of usage, this amounts to a map function of [#ca-001]
emissions:

  • the session has a method that produces an emission handler.
    (`to_emission_handler`, cross-referenced to here.)

  • the session can be constructed with and/or has a writer for
    an emission handler.

this first handler acts as the "ears" *of* the session - the session
receives emissions though this and transforms them according to the
below and subsequently sends the modified emissions into the second
handler.

this same "session" instance should be capable of handling any N
number of incoming emissions, each without altering its own state
(because of its above-mentioned "dup-mutate" implementation).

depending on things like how the client uses it and intrinsic
characteristics of the modality, however, it may be normal for a
constructed session to handle only one emission.




## aspects around which transformations can be requested

the various settable DSL-like attributes of the session determine
how the emissions are mapped. these are some of the aspects that
this facility is sensitive to:

  • whether the emission is a [#br-023] "expression" type or
    whether is is a traditional, event-shaped one. (these are the
    only two shapes of emission assumed to exist).

  • if there is a [#ac-031] selection stack, the session can
    express this stack in a variety of ways.

  • the session can derive a "trilean" "polarity" (i.e negative,
    neutral or postive) from a variety of characteristics of the
    emission channel and/or (when event) the event properties.

    with this trilean value and a verb "lemma" that it derives
    (somehow) and an "entity noun" that it derives (somehow)
    (here we'll say it's "foo"), the session can for example inflect
    the lemma into the inflected forms of (for example)
    "failed to add foo", "while adding foo", "added foo" as appropriate.



## code nodes

### ( "A" and "B" (the old way of parameter representation) were sunsetted. )

### ( "C" is in-situ )
_

# #tombstone this used to be the first document whose contents were gleaned from the [#bs-014] `deliterate` utility.
