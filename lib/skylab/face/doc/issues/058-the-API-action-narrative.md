# the API action narrative ;[#058]


## :#intro

this API::Action base class reifies the API API so that in your API
Action you can focus on your business logic and let everything else fit
together like magical greased lego's.

everthing is of course experimental; but note it is a very designed,
thought-out experiment, with both eyes focused squarely on the big dream.

the API Action lifecycle :[#021]:

the lifecycle of the API Action happens thusly (ignoring how we got
to an API Action instance for a moment):


[_this_state_] -> `will_receive_this_message` -> [_and_go_to_this_state_]

    [primordial] --o          just been created. no ivars at all (as far
                    \         as this API knows). is is probably right
                     \        after a call to `new`     [#016]
                      \
                       o->   expression/event wiring    [#017]
                        /
                       /      resolves how to express itself: any
    [wired]      <---o        listeners subscribe to its events, and/or
                 -o           it gets an expression agent set.
                   \
                    o--->   `resolve_services`          [#018]
                       /
    [plugged-in]  <---o       it resolves fulfillment strategies for
                  -o          the services it declared as using, e.g
                    \         implemented by a plugin subsystem ([fa]? [hl]?)
                     \
                      o-->  `normalize`                 [#019]
                        /
    [executable]  <----o       with its formal and/or actual parameters,
                  -o           with all its field-level assertions of
                    \          correctness that can be represented
                     \         declaratively (think DSL), assert them
                      \        now, result is soft failure or ivars.
                       \
                        o-> `execute`                   [#020]
                         /
                        /      we now run this method that you wrote,
                       /       with your business logic in it.
    [executed]    <---o        probably we are done with the action now.

The sequence of the steps above is based (perhaps aesthetically and/or
arbitrarily) on the notion that each successive state might depend on the
state before it: executing of course happens at the end, normalization
may require services, resolving services (and, more likely normalizing)
may require that the action has event listeners wired to it. wiring event
listeners requires nothing.

Each of these steps may also have corresponding DSL-ish facets that this
class reveals (namely, `listeners_digraph`, `services` and `params`) which we present
below in the corresponding order and inline with the corresponding
instance method (callbacks) enumerated above. So, any time you wonder
where you might find something here, think to the lifecycle first. yay.

we break this into numbered sections corresponding to the lifecycle
point. there is for now no "section 1" because we are avoiding
implementing an `initialize` here, wanting to leave that wide open for
the client, which we will one day document at [#016].
there will be no "section 5" because that is for you to write.

[1] - and/or it get an expression agent set



## :#storypoint-10

we frequently want the facet-y DSL calls to be processed atomic-ly,
monadic-ly, er: zero or once each; for ease of implementation. can be
complexified as needed.



## :#storypoint-15

fulfill [#027]. public. for this facet we default to true to let a modality
client decide how / whether to wire the action for itself (although we
override this method here in a sibling class..)
