# node parse :[#015]

this process cannot fail: given a known compound node (i.e "ACS")
and a (possibly empty) argument stream, result is a stack (array)
of one or more "qualified knownness" (or similar) that emerge from
the arguments whereby:

Start with:

  • the stack will always start as being one item tall, the item
    being a known known of the argument ACS. this is for algorithmic
    convenience of the caller that wants the "whole stack" reflected
    in the result, including the ACS that we started from.

Then:

  • if the argument stream is empty, we are done.

  • if the head of the stream does not correspond to one of the
    ACS's associations, we are done.

  • if the optional `stop_if` proc was provided, the current
    association is passed to it. if this call results in true-ish,
    we are done.

  • if the current association looks compound, "touch" it. this new
    ACS becomes "the" ACS. add this as a qualified knownness
    to the stack. start over from the beginning of this list.

  • stop as-is. we are done.


Usage Considerations:

  • at present we consume tokens off the stream *IFF* they are for
    compound nodes. this gives the caller more flexibility (and
    responsibility) for how to implement her own syntax with regards
    to what happens after the segment of "compound selectors" in the
    argument stream.

  • as stated, this process cannot fail. upon receiving a result
    stack that is shorter (or longer?) than expected, the onus is on
    the caller to effect behavior appropriate for her syntax.

  • we work "passively": although this process must finish when the
    end of the argument stream is reached, it is possible for this
    process to finish before then. the caller is responsible for
    checking for and dealing with any remaining argument items.

  • despite its taxonomic position, this node is not for resolving
    operation nodes. it is here because the implementation of
    operations frequently involves resolving an operand through a
    a process like this. (if we *do* add such support through this
    mechanisim, it must be opt-in only so we don't break existing
    clients in the future that rely on the current behavior.)


Design Considerations:

  • if we change any of the behavior described in the above, it
    must be as an opt-in.

  • when we enounter compound nodes that are not yet built, we must
    build **and attach** them ourselves so our algorithm can continue.

  • although currently we cannot conceive of how this would work
    fully given everything, we might try to use this same API node
    to ellicit fuzzy behavior, whereby the argument stream is strings
    and etc.
_
