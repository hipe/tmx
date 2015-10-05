# the action factory narrative :[#046]


:#note-135

.. this makes three categories of "proprietor" that can define
formal properties for us:

  1) our selves, the action
  2) the preconditions
  3) the model class

we have no clobber policy about which of these three sorts of
proprietor should be able to trump which other ones when defining
formal properties. put more explicitly, our policy *is* "no-clobber".

instead we assert that each of the sorts of definer nodes above must
be aware of all names it might get from its upstream nodes as
appropriate:

this means that those formal properties that a silo might give to
its depender actions must be a fixed part of its public API.

this also means that if a silo is to use the action factory, it
must be aware of those adverb and ancillary formal properties it
will get from the action and its precondition silos, respectively.

ulitmately the formal properties can be (and often are) held in an
implementation of a mutable box, so if necessary the action can
always add, remove and edit properties arbitrarily as necessary; if
this policy is problematic.
