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

  • it is or will probably be [#sl-023] dup-mutate compatible.

in one form of usage, this amounts to a map function of [#ca-001]
emissions:

  • the session has (in effect) a reader method that results in
    an emission handler.

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

### :"A"

borrowing language from [#ca-004] "knownness" theory (but not sticking
to it to the letter), the topmost structure (the session) works with
a statically defined list of N number of "knowns". (think of this as
an array of hard-coded symbols.)

each of these has what we will call a "formal known" and an "actual known".
the "formal known" refers simply to the presence of this item in the
static list.

the "actual known" for any given "formal known" can be in a variety of
states that mimics the referenced theory conceptually but differs
in implementation:

a "knowns" object is used to store and report the "knownness" for any given
formal known.

some formal knowns can be validly `nil` and/or `false`. for these formals,
the "knowns" object must be able to report whether or not an actual
value is known for the formal, as distinct from being able to represent
what that value is if it's known. we will refer to these formals below
as being in category (A).

for all formals that are not in this category, we will refer to them
below as being in category (B).

  • IFF the actual value for the formal is unknown, then the value
    resulted by the knowns object is false-ish.

  • otherwise, (and the actual value for this formal is known), how this
    value is resulted by the "knowns" object depends on what category
    the formal is.

    * if the formal known is in category (A), then the value resulted
      by the "knowns" object is [#ca-004] "known known" structure.

    * otherwise (and it is in category (B)), then the value resulted
      by the knowns object is the actual value of the formal.

probably none of this will make sense unless you have had to work with a
situation where category (A) is necessary.




### :"B"

building on the above, we store the representational value from the above
(when known either a known known or an an actual value) in a plain old
ivar whose name is derived from the formal name. there is a plain old
reader method for each formal. this means that system-wide, each
participant must know into which category the formal falls into to make
sense of the values it receives from queries into the knownness of any
given formal.





### ( "C" is in-situ )
_

# #tombstone this used to be the first document whose contents were gleaned from the [#bs-014] `deliterate` utility.
