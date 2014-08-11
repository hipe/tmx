# the [cb] digraph narrative :[#019]

## :#storypoint-1  introduction

Welcome to [cb] digraph, née "pub-sub emitter." this was the first "really cool" event model in
the skylab universe, but it has now fallen by the wayside. it continues to be
essential to sub-products that were built around it and remains a fun
and somewhat pure experiment. indeed it may yet demonstrate some value in the
future with its primary mechanic, value that we may either fold into the event
models that superceded it, or leverage anew with a simplifed overhaul to
this node.

having said this, please bear in mind that while some code may appear new
because of this most recent round of refactoring, it is in fact both old
and deprecated especially around #storypoint-10 and more broadly anywhere
having to do with the generating of event objects. the first misstep that
this library took is that it ever concerned itself with the production of
event objects.


## :#storypoint-2

Traverse up the chain of every ancestor except self (and self is not in the
chain if we are an s.c), (also we (ick) skip ::Object and ::Kernel and
::BasicObject for ridiculous OCD reasons) while searching for module that
`respond_to` `event_stream_graph`, and when one such module is found, add it
to a list, and if ever one of these modules is a class, stop right then and
there, assuming (if we understand the ancestor chain correctly) that
inheritence itself (in conjunction with this facility) will work as expected

All of this craziness is to allow the merging of graphs atop the ancestor
graphs to see if that is a thing that is useful, but of course, it is all
#experimental so use with caution.

EDIT - to work with ruby 2.0's `prepend` module, we have to accomodate some
things. in so doing i think we improved it a bit.


## :#storypoint-3

this method is the central workhorse of `call_digraph_listeners`. if the argument symbol is not
in the graph, result is undefined.

otherwise, result is an enumerator of names with the argument always being the
first one and the remainder enumerating in pre-order over the elements of the
unique set of all the association target names (direct and indirect) of the
argument symbol.


## :#storypoint-4

for now it is the policy of this library never to add destructive public
instance methods (e.g something that adds a listener to a stream, etc.). those
instance methods that have side-effects (e.g. ones that add listeners to a
stream or emit events) are by default private. as appropriate to the design
of the application the client must publicize the desired destructive methods
explicitly.

however we may still add some *non-destructive* public i.m's below


## :#storypoint-5

this method adds a listener to a stream. for any stream `foo` it is more
readable and hence idiomatic to use the `on_foo` method rather than this one.
this method was created to be employed when the particular identity of `foo`
is determined programmatically.

it must be public both because its typical sender will be an outside agent
attempting to wire this one, and because the outside frameworks may depend on
its public existence; hence it is part of our fixed, public API :[#020].


## :#storypoint-6

NOTE we try something here as one of many different attempts at a solution for
a familiar design problem that yet has no name - the below 3 methods trigger a
call to `init` which hackishly adds another module to the ancestor chain of
the singleton class of the object, which in turn overrides these methods!!
this is done so that we don't have to check for whether the thing is initted
each time we for e.g. call `call_digraph_listeners`, and in theory it will only get us in to
trouble if we use alias_method on the below three #experimental

#todo this is a truly terrible way to do this and should be swapped out withx
 an `initialize` hook if possible


## :#storypoint-7

about this `init` method:

• we collapse the particular graph here (i.e we decide what graph is
  your graph, be it from your singleton class or your class.)
• it is memoized to a proc for devious reasons.
• you can always clear the ivar and/or set it to whatever yourself.
  for each of the below 3 things, some clients will have set their
  own before they get here (e.g h.l table with it's experimental
  shell / kernel pattern omg)


## :#storypoint-8

`build_event` - this is both a convenience for clients that want to
build an event for whatever reason, *and* it can be extended and
wrapped by a class that wants to touch every event that it emits.
it cann even be re-written completely, for e.g to pass more or different
info to your factory, or whatever.


## :#storypoint-9

`if_unhandled[_non_taxonomic]_stream[_name]s` - a suite of *instance* methods
as a facility for checking that you are handling all of the event streams that
you care about.

the above name permutes out to 4 methods each of which has the same argument
signature: its arguments must fall into one of the following forms (that
expands out to many permutations (seven?)):

`argument_signature` ::= & block
                     | <callable-ish> [<callable-ish>]

`callable-ish` ::= ( proc | symbol )

the one-block and one-callable forms are isomorphic in the expected way.
a symbol will be "expanded" into a proc by calling `method` hence the receiver
must implement a method by that name somewhere (#todo give example of this).

these `if_unhandled_[..]` methods all resolve list of stream names that
represent those streams that do not have any listeners connected to them
[#todo it begs the question..]. we will herein refer to this list as
"the result list", even though the list is not (necessarily) the result of the
method call, as we are about to explain.

if you called the `_non_taxonomic` form it assumes that the emitter has set a
list of `taxonomic_streams` whose names will be excluded from the result list.
if the emitter does not know of any taxonomic streams at all a runtime error
is raised (which avoids accidental silent failure of the ultimate intended
purpose of this whole thing).

the argument signature resolves-out to two functions: if a second
<callable-ish> was not provided it is effectively the same as using `-> { }`
(the no-op function). the first function will be called if the result list is
of nonzero length, the second if not. the result of the `if_unhandled_[..]`
call is the result of the function called.

for the `[..]_names` form of this method, when there is a nonzero length list
of unhandled stream names, the first function will be called with the array
of names as its sole argument. alternately, if the `[..]_streams` form was
called, a rendered message string is passed instead of an array.

to raise a runtime error if there are any unhandled stream of self -

  if_unhandled_streams :fail

(which is equivalent to:)

  if_unhandled_streams method( :fail )

(which in turn is equivalent to:)

  if_unhandled_streams { |msg| fail msg }

(idem:)

  if_unhandled_streams -> msg { fail msg }

to be about as ornate as possible:

  ok = if_unhandled_non_taxonomic_stream_names -> name_a do
    puts "these stream(s) are not handled: (#{ name_a * ', ' })"
    false
  end, -> do  # else
    puts "all (non-taxonomic) streams are handled."
    true
  end
  # ..

(this explanation leaves room for improvement, but the above is
everything there is to know, in an albeit condensed form.)


## :#storypoint-10

`Callback::Event::Unified` - when you want your events to be just simple
datapoints like strings or numbers (or any single arbitrary object),
that you want to emit out to listeners, you will not have to use this
(but you instead will have to wire a factory, which may just be one line..)

Out of the box the Callback::Event::Unified doesn't know how to render
itself or its payload, because that depends on the payload itself,
the application and the modality. But what it *is* for is for when
you want the event object itself to be able to reflect metadata
about the event, like `e.is? :error` or `e.touched?`. *or* you plan
to corral all of your events through e.g one filter or aggregator
and you want them all to have the same core interface. (this used to
be how it was always done before we realized that datapoints were
more elegant for some problems.)

(Historical note: we used to rely on this heavily when we would do
contorted hacks to contextualize and decorate event messages, for e.g.
changing its message by prefacing a verb and a noun constructed from
a fully qualified API action name.. but we may be trending away from
it now in lieu of carefully wired factories, and carefully constructed
stream graphs, and custom (and lightweight) event classes per-application
.. let's see..)


## :#storypoint-11

`initialize` - *highly* #experimental args. handling of payload is left
intentionally sparse here, different applications will process and
present payloads differently.


## :#storypoint-12

consider also just wiring a factory that creates as an event objects just
pure text ..
