# Towards an event wiring pattern

(this originally appeared in a comment in a sub-product. although the
issue was resolved in the source code at that location, the spirit of
the comment still holds..)

wiring should happen between the api action objects and the "client"
(interface) instance that invoked the api action.
all.rb does this confusing thing by having non-configurable core
clients.
