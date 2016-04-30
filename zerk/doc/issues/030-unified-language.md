# unified language :[#030]

## (for perahps all 3 bundled modalities)

  • "stack frame" - a frame on the [#ac-031] "selection stack"

  • "scope set" / "stated set" / "bespoke set" / "socialist set" - see [#027]


## (for iCLI)

  • most of niCLI terms too

  • "atomesque" is both primitivesque and entitesque
    (they get very similar expression here)

  • what we used to call a "frame" (as in "UI frame") we now call a
    "panel" so as to avoid cognitive collition with the all-important
    stack frame.




## (for niCLI)

  • *all* unified language in [#ac-030] is inherited to this sidesystem!
    (this may change if it becomes difficult to maintain.)

  • we no longer say "node" in an unqualified way:
    + if it's a component, say that.
    + if it's a formal operation or an association, say that.
      (to be indifferent to which one it is, say "formal node".)
    + if it's a "node ticket", say that
    + if it's a "node entry", say that (very low-level)

  • compound. (don't say "branch" here.)

  • primitivesque. (don't say "leaf".)

  • "navigational" nodes are the compounds and the operations.

  • "non-compound" are primitivesque and operations. (don't say "leaf".)

  • "3-normal shape category" - this unfortunate name is a conceptual
    reduction and flattening of the categorical taxonomy of nodes down
    to simply `operation`, `compound`, `primitivesque`.
    (unfortunate indeed - you forgot "entitesque".)




### "frame"

in niCLI the (selection stack) frame holds a lot of responsibility..




## evaluations, reasonings, emissions, and states

  • a "reasoning" (:#A) is structure that can be used to help explain
    why a particular node is unavailable. it has the structure:

         +----------------------------------+
         |           reasoning              |
         |                                  |
         |  • `compound_formal_attribute`   |
         |    (a formal operation)          |
         |                                  |
         |  • `emissions`                   |
         |    (an array of [1..] emissions) |
         |                                  |
         +----------------------------------+

    it groups together the formal operation that was attempted to be
    invoked and an array of one or more emissions of would-be events
    that should on their own explain why this formal operation was
    unavailable.

    (prototyping logic may assert that this array is always exactly
    one element long, asserting that in effect a reasoning is one-to-one
    with an event; which might shortterm make things easier to implement:
    #open.)

    it is called "reasoning" and not "reason" for the general reason
    that "reasonsing" is more vague than "reason" and the specific
    reason that "reason" is singuar, whereas a "reasoning" could perhaps
    hold mulitple reasons why a node is unavailable.



   • an "emission" is based on a [#ca-045] similar idea elsewhere:

         +----------------------------+
         |          emission          |
         |                            |
         |  • `channel`               |
         |    (array of symbols)      |
         |                            |
         |  • `mixed_event_proc`      |
         |     (either builds event   |
         |     or expresses strings)  |
         |                            |
         +----------------------------+

     an emission structure captures a [#ca-001]-style emission,
     in terms of the "channel" it was emitted on and the proc that
     can be used to build the event or express the expression.

     for our purposes here, these emissions are presumably *error*
     *events* (not expressions) .. maybe ..




  • an "evaluation" for now has the same conceptual structure as a
    [#ca-004] knownness, and in fact we use that very library to
    represent them. the "known unknown" from there has been modified
    (in the remote) so that it can hold a reasoning object optionally.




  • a "state" (in one particular domain) is mainly used to resolve
    graphs while detecting cycles. once the graph is done being
    resolved, the "state" functions as little more than a wrapper
    around an evalution.
_
