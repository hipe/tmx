## The common triad :[#019]

.. refers to the convention of meanings assigned to a result from a
function in the context of a headless application, specificly in the
context of processing an request ("action"), but also sometimes used
more broadly. This is experimental, and probably has one or more smells
associated with it, but so far has been used to desireable effect.

The convention is: for functions that state that they follow the
convention, the following three meanings can be inferred from which of
the three below sets of values the result value falls into:

  1) nil - if the sub-client's final result (or the result of a
  sub-client's participating method) is nil, it is to be taken to mean
  that the sub-client is saying, "We encountered something that constitutes
  as an exceptional early stop, and we think that no further processing
  should be done. If it were up to me, we could just exit right here
  and now."

  (this is still the sub-client talking,) "Based on my understanding of
  what is being requested, I think that no more information needs to be
  emitted to the client. This might be because I think I have fulfilled
  an exceptional end-goal of a request (i.e. just create some file or
  call_digraph_listeners some debugging info, then exit). It might also be because some
  necessary resource was unavailable, in which case I have emitted events
  expressing information to this end."

  In any case, the bottom line is that `nil` is the sub-client's way of
  saying that it thinkgs no further UI events need to be emitted to the
  client at all.

  2) false - if the sub-client's final result (or the result of a
  participating method) is false proper (and not just false-ish),
  it is like the "exeptional early stop" of nil above, except that
  the sub-client thinks that more events should yet be emitted to fully
  express the fact that we reached an exceptional early stop.

  A common use-case for this is with invalid request data. The
  sub-client will call_digraph_listeners what specifically was "wrong" with the parameters,
  but expects that the client might further want to, from a UI
  perspective, contextualize this emission with e.g. UI that can lead
  to more help or futher information.

(So, note that both `nil` and `false` essentially mean "exceptional early
stop", and are both false-ish. We will pick back up with this point below.)

  3) the third and final set of results that a participating sub-client
  or method can result in is "true-ish" (i.e "everything else.)  The
  specific shape of the data will vary (watch for smells here). A
  result of true-ish is the sub-client's way of saying "I did what you
  asked for / here is what you asked for, please procede governor."
_
Nodes that don't much care about the distinction between 1 and 2 above
can just bubble the same false-y value up the call stack until someone
who cares absorbs any meaningful false from it. (Then what they would
typically do is themselves result in nil.)

One desireable thing this grants us is a relatively simple way to have
what amounts to a rudimentary event propagation model without needing the
cognitive and other overhead of something more overwrought.

But the bottom line is, it's all just experimental!
_
