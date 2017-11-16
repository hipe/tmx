# the selective listener pattern :[#001]

## synopsis (in slightly more than one page)

the selective listener pattern is an interface recommendation for
producers of "potential events" and consumers of those "potential
events".

this is far and away the de-facto standard ("lingua franca")
event model in this universe. (the previous, inferior models are
listed in an upcoming section.)

the salient charactersistics of this model are:

  • events are not built (we say "realized") unless there is a desire
    to consume them. this choice of whether or not to realize any given
    potential event is made by the consumer (if any), not the producer;
    and it is made lazily at "emission" time.

  • as such, rather than speaking of emitting *events*, we conceive
    of the role of the producer as emitting *potential* events.
    (EDIT: more frequently we simply say "emissions" nowadays.)

  • the role of the consumer in this model is to *decide* on each
    potential event it receives (we say "emission"), whether or not
    to "realize" that event.

  • in order to faciliate the above, the producer has (either as
    intrinsic member data or as a block passed to some method) a
    "selective listener proc" (known idiomatically in the code
    as variants of as `listener` or `p`).

  • the producer emits potential events by calling its selective
    listener proc with N args and a block. *each* of the N args
    *must* be a platform symbol.

  • the N args passed to the selective listener proc constitute what is
    effectively an array of symbols. we call this the "channel" of the
    potential event. this is what is used by the consumer of the
    emission to determine whether or not it is realized. (see
    [#]soft-standards-for-channels below.)

  • the block is concerned with producing the event (somehow).

the above idea generally is now recognized in code by the `Emission`
structure defined by the topic sidesystem. this structure consists of
nothing but N symbols (where N is positive nonzero) and a proc. the N
symbols represent the the "cateogory" or "channel" of the emission. the
proc has a mixed shape that is determined by the sidesystems or
applications that use them, but generally the produce an event structure
or effect behavior.




## the key cost

the main potential "drawback" of this eventmodel is that it is
intrinsically synchronous (we think). in a non-concurrent model, the
producer of the potential event is blocked, "waiting" to see if the
consumer wants to realize the event or not. given our current platform
this has been a non-issue, but is still something to consider.

however it bears mentioning that this "drawback" is not intrinsic in the
model itself but only in the way we typically implement consumers of
potential events:

if we were to try to apply this to some kind of asynchronous
model, we could disregard all concern for [#ac-002]#DT4 "conservatism"
and realize every event at every emission regardless of who is
listening in order to pass these off to a queue or whatever. the
potential event producer need not have knowledge of such an
event model change, which is part of the beauty of this model.




## applicability & scope

the selective listener pattern is one of "the universe"'s greatest
contributions to society. this event-model (or broad pattern for
event-models) subsumes (and builds upon) the idea expressed in:


  • [#023] an excellent overview of 5 event models.

  • [#043] the "subscriptions" model

  • [#019] the "digraph" model (once called "pub-sub")




## :soft-standards-for-channels

a strong and particular set of "soft standards" has emerged for the use
of the "channel" part of emissions:

  • in implementations of this model "in the wild", the first element of
    the channel is very frequently `info` or `error`. (but projects are
    free to extend or ignore this convention as useful.)

    the [#ac-006.J.2] "mutated" "signal" is an example of a custom front
    channel element with special (and important) semantics.

    we don't want to think of this as a "formal element" per se (because
    consumers should expect to receive emissions with perhaps any channel
    value), but for the sake of reference in this document we'll call
    this formal element the "broad category".

  • sometimes the second element of the channel can express something
    about the "shape" of the potential event, as the [#br-023]
    `expression` signifier. the default assumption for "shape" is
    typically a [#003] structured event, but this is not proscribed
    by this document or model.

  • some [#br-002] "modality clients" require that there always be a
    "descriptive" channel element (necessitating at least either 2
    or 3 channel elements, assuming that there is always a "broad category"
    element and perhaps one "magic" element (corresponding to the two
    previous bullets).




## supplemental reading

  • [#003] the event narrative describes the internals of our structured
           event class (it is not required that you use this class)

  • [#005] "event makers" covers a collection of alternative,
           experimental, and/or "macro" style nodes that produces events
           of some shape somehow.
*(archival content below the line, still here for posterity & processing)*
--

# this historic document..

.. has been converted to note-taking scratch, to this end: we wish to
turn "event factory" into a grain of sand.




face                q [X] unified, OK
porcelain           Q [X] textual, unified, OK
headless            q [X] isomorphic, OK
callback            q [X] unified, OK

permute             Q [X] isomorphic, OK
dependency          Q [X] textual, unified, OK
code-molester       Q [X] structural, isomorphic, OK. (last both)
sub-tree            q [X] textual, unified, OK. (last both)
treemap             Q [X] datapoint, explicit OK (last both)




unified 5
textual 3
isomorphic 3
datapoint
structural 1
explicit 1
late 0





# The Signature of Emit :[#001]

(EDIT: this document is historic and is largely deprecated by point [#035])

Life is much easier and more readable if you assume a syntax like:

    call_digraph_listeners type, *payload

where `payload` is often a single string.


However, remember these other important and essential variations of `call_digraph_listeners()`:

  + when the event has no metadata, like `call_digraph_listeners :done`
  + when you are [re-] emitting custom event object, like `call_digraph_listeners my_obj`
  + emissions with structured metadata: `call_digraph_listeners :nerk, ferk: "blerk" ..`

Etc.  For this reason we have to assume that `call_digraph_listeners`() takes one or more
parameters and we have no idea the shape of the parameters.


## what to do about it

In some applications an action will somehow get a hold on a particular
event (e.g. from an API call), and want to re-emit its own "version" of
that event; and by that we mean take the same payload of the previous
event, but emit a new event that has a different stream name and is
under the different event stream graph of that new action.

A hackish way to accomplish this that saves on lines of code *and*
memory *and* execution time is simply if the new event's `@payload_a`
member is simply a pointer to the exact same array of the original
event. This is a big experiment, and will definately pose problems
unles we agree that:

1) `@param_a` should be one-time write only immutable, and should always
be the exact contents of the `rest` args to the original `call_digraph_listeners` call or
equivalent.  Further sub-processing of payload args should be considered
derived properties stored in e.g other ivars.

2) it then follows that useful higher level operations
on the payload (like "message") will be derived properties that will
live e.g in instance methods, and we will have to accomodate that when
the event is effectively changing classes.
