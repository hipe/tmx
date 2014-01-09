# the infrastructure narrative :[#004]


## :#in-API-invocation-the-order-matters

to keep things simple and orthogonal, the order of the iambic terms matters
in the beginning: a locator for the action you are invoking must come first
(preceded by the appropriate keyword term), no exceptions.

this, despite how tempting it is to pass a listener or a client as the first
pharse so that subsequent errors with resolving an unbound action can be
reported through the listener rather than raising an exception no. that's not
how it works in this family.

if you want to be all sexy with the listeners then fine, to that in your API
action. it is outside of the scope of the API session to deal with listeners.
