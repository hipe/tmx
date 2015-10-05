# the subscriptions narrative :[#043]

## introduction

subscriptions is a flat list of event channels given simple symbol names
(see #channel-name-conventions below).

you create a subscriptions class with semantics similar to that of
creating a struct class, and then you create an instance of this class to
manage a particular set of subscriptions along particular channels from
a sender to a receiver.



## it is a simplification. what it is not:

### it is flat, it is not a tree

a subscriptions is a *flat* list of event channels, meaning that it is not a
tree of related event-channels as is done with [#019] digraph (neé "pub-sub").

however, rudimentary set operations are possible with calling
`subscribe_all` in conjunction with unsubscribing to particular
channels; the same effect of which was the 90% use-case of modeling
event channel trees.


### it is not a muxer (yet)

unlike digraph, with subscriptions you cannot stack multiple callback
procs into a single channel (that is, you cannot have multiple listeners
to one channel). although it would be trivial to implement, we never
really needed this feature in the first place.

also, were we to implement this now we would do it differently: now we
hold the belief that it would be a smell to introduce such a facility to
the subscriptions structure itself. rather we should create a *simple*
muxer that operates for only one channel and its list of listeners.
this is a better separation of concerns.



### it is not as intrusive

the old digraph way necessitated that the sender-ish be mutable to be
able to receive callback proc assignments through `on_foo`, `on_bar` etc,
effectively treating it as a high-level DSL-ish shell; which was
potentially problematic in that its mutability was in question
throughout its lifecycle, as well the fact that it polluted the namespace
of the would-be sender with the generated and static methods that related
to setting the callback procs.

with subscrptions it is the subscriptions object that is mutable, not
the sender.


the old digraph (pub-sub) way:


           +--------+                            +-----------+
           [ sender ]  ------------------------> | receiver  |
           +--------+                            +-----------+
                         (mixed shape events)


the new subscriptions way:


     +--------+             +---------------+            +----------+
     [ sender ]  ---------> | subscriptions | ---------> | receiver |
     +--------+             +---------------+            +----------+


in the new model the sender is free to be any shape it wants, and perhaps
be immutable. the receiver now needs (maybe) to implement one method,
`receive_event`.


other useful corolloaries come from the new model: given this
de-coupling, the particular sender and/or particular receiver can be
swapped out and in for any particular subscriptions object at any time.

for example, you can configure what channels are subscribed to before the
sender or receiver are even known.




## :#channel-name-conventions

typically the names of "channels" in a subscriptions class will end in a
noun describing their shape, like "_event" or "_string". (it is
recommended always to go with "_event" unless events are being used
universally in the application.)
