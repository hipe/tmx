# introduction to operations :[#009]

we say "operations" as a general term to refer collectively to
disparate but related phenomena that the [ac] facilitates:

  • an "imperative phrase" has as perhaps its only mandatory
    component a token representing an "operation" (verb).

  • "formal operations" can be recognized by our expression &
    interpretation facilities for use both by our native
    "imperative phrase" (i.e mutation session) facility and
    for use by "third party" tools that adapt to particular
    intents like serialization and interfaces.




## the "operation" term in an "imperative phrase"

the ACS assigns no special meaning to the various one or more verbs to be
supported in edit sessions (unlike in its earliest incarnation where
there was a hardcoded set of around five collection-oriented verbs with
implementations!). nowadays, the set of supported verbs is determined
entirely by the subject component.

there are some syntactic constraints on what the verbs can be.

we explore each of these points now:




### syntactic constraints & considerations

each "imperative phrase" contains exactly one "operation verb".

grammatically the only requirement by the ACS for these verbs is that:

  A) the operation verb cannot be one of the modifiers
     (keywords) described in [#002]#Tenet7 (an ever expanding list..)

  B) the operation verb must occupy exactly one token. (but of course
     you could use underscores to express multiple words in one symbol,
     to implement for example an operation named `clean_up`.)




## about the definition of operations

each "verb" that is to be supported by your imperative phrases must
correspond to one operation definition per ACS (class, usually) that is
to support those verbs.

because this is in flux, here are some semi-disparate points:

  • it seems we have specialized into two broad categories of operation,
    one we will call "transitive" operations, and one we will call
    "formal" operations.

  • "transitive" operations were the first kind implemented - more below.

  • a "formal" operation is one that can have arbitrary metadata
    associated with it and [will eventually #when [#009]] supports
    a variety of implementation options (procs, classes..)




## brief introduction to "transitive operations"

  • the term "transitive" may change. we use it for now because it is
    shorter than the more accurate "collection-oriented operation",
    but it is a bit of a misnomer: grammatically these constructions
    resemble transitive verbs only loosely and supriously.

  • for now, for a transitive operation to be "picked up" by the
    imperative parse it is necessary that the component to be the
    *object* (right-hand side) have a component association that
    accomodates the operation in the following way:

    each such component association must list each applicatble verb-
    symbol it is compatible with in this way in its list of
    "transitive operation capabilities". this both defines the
    acceptible set of components that can be passed as arguments to
    any particular transitive operation; and guides the parse..




## defining a transitive operation

imagine that we have a verb token `foo_bar` that (by whatever means) has
been decided to be treated as a transitive operation as opposed to a
formal one.

this operation will require that a method something like:

    def __foo_bar__component x, ca, & pp
      # ..
    end

the above signature will change when #open [#012] so we don't document
it for now..

the meaning of the double underscores is explained in [#002]#Tenet4.

the true-ish- or false-ish-ness of the result indicates to the ACS
whether or not the "delivery" of the operation succeeded. an operation
that fails delivery will lead to more or less immediate exit from the
edit session, regardless of any remaining operations in the "queue" for
that edit session.

in cases of success, the implementor may chose to result in the same `x`
(component) that was passed to it so that this component "bubbles out" and
can be used as the final result of the edit session (which can be useful
for edit sessions that build or remove items where the caller may want to
do something with this item). but note this technique cannot be used for
models where the component can be valid-ly false-ish. (rather, look into
using the "value wrapper" if you really need to.)
_
