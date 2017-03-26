# predicateish theory :[#056]

## 1) what the verb needs to express itself is in two places

as anyone reading this likely already "knows", EN verb conjugation
involves verb "agreeing" with the particular exponents of certain
grammatical categories of the subject (specifically, `count` and
`person`). (from our perspective this sort of mechanic is equivalent
to inflection, but we try to use the remote jargon when it is known.)

there are other sorts of "inflection" exhibited by the EN verb that
are arguably more important: whereas "conjugation" is effectively
superflous (never adding new information to the utterance beyond
perhaps socio-political information), inflecting for verb *tense*
(for example) *does* add information we deem valuable.

nonetheless, all these grammatical categories are equally important
when trying to produce "well formed" surface representations in EN.

in our model, this "predicateish" carries some but not all of this
"inflectional state" needed to inflect the verb: verb-tense-like
exponents live here, but those grammatical categories that are a
function of the verb's subject live *in* our "predicateish":


    +-------------------------------------------------------------+
    |                          statementish                       |
    |                                                             |
    |  for subject noun phrase:          for verb phrase:         |
    | +-----------------------+    +----------------------------+ |
    | |       nounish         |    |        predicateish        | |
    | |                       |    |                            | |
    | |    • has `number`     |    |      • has `tense`         | |
    | |    • has `person`     |    |      • has `polarity`      | |
    | |                       |    |                            | |
    | +-----------------------+    |                            | |
    |                              |  for object noun phrase:   | |
    |                              |  +----------------------+  | |
    |                              |  |      nounish         |  | |
    |                              |  +----------------------+  | |
    |                              +----------------------------+ |
    +-------------------------------------------------------------+


    fig 1. of the exponents we will need to inflect a verb, some of
           them live in the subject, and some in the verb phrase.

we used to store an entire other "verb phrase" from the POS library
inside this verb phrase, but that approach did not scale out to work
with aggregation..




## 2) we must use POS as a short-lived session, not a long-term store

the reasons generally that we started writing this new sweep of similar
things generally holds as the particular reasons that we don't hold the
legacy phrase structures as long-running member data:

  • we want to leverage the new [fi] attributes to model the components

  • aggregation - we need phrases to play with the aggregation API

  • `dup` - we want to control how `dup` works on our phrases
