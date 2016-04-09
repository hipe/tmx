# "normal representation" :[#027]

## intro

per [#009], an "operation" can manifest in a variety of forms of
implementation (e.g method, proc or non-proc); and it can be applied
towards a variety of purposes (e.g as a "transitive" operation or a
"formal" operation). we maintain "normal representations" of operations
to present a unified façade through which we interface with operations.

the normal representation is furthermore intended to be divorced from
modality-senstive concerns, so that it can be useful outside of the
immedate scope of the modalities that [ac] supports alone.




## hypothetical objectives

[ac] doesn't do all these fancy things, but supports an API that
facilitates the implementation of them:

  • the [ac] maintains (at present) three adapters for three
    implementations of operation, all of which expose the salient
    characteristics of the operation as a "normal representation" (that
    is, plain old adapter pattern).

    (they are "method-based", "proc-based" and "non-proc-based".)

    what the "salient characteristics" are is determined as a product of
    what the design objectives are as suggested by the remainder of this
    list.

  • pursuant to the implementing library (not [ac]), if the parameters
    in a formal operation's "normal representation" have names that
    correspond to nodes in the [#031] "selection stack" of this formal
    operation then the implementing library may want to implement
    recognition of this reference (somehow).

  • again not implemented here, but those references from above may be
    pointing to other requisite operations, not just other "atom-esques".
    (when and how the requisite operation is executed is not specified
    here.)

  • for the operation implementations that are not method-based,
    the normal representation can express its "constituency" as a
    stream of "formal parameters".

  • each such formal parameter can express its [#fi-014] "parameter
    arity". (most essentially, this is to determine required-vs-optional
    parameters; a concern that we implement in this library at [#028].)




## :"preparation"

a "preparation" session is for producing bound calls (or similar) from
formal operations.

note that the preparation knows what a deliverable is but only thinly.
we want it to be used equally well to make bound calls for other
libraries.

the preparation is meant to be totally ignorant of modality specifics.




## :#expanse

the "expanse stream" is a stream of [#020]-like formal parameters.

  • each such parameter is *not* associated with its (any) referrant
    component association or formal operation.

  • the expanse stream is what is used to determined which parameters
    willl be run through [#028] our normalization routine. see
    "limited scope" there.
_
