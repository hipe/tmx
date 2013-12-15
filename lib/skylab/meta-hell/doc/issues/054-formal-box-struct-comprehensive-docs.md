# comprehensive formal box struct docs :[#054]

## introduction & purpose

sometimes you want to 'freeze' the box down into a struct-like,
so you can access the members with methods etc, or just generally
have it behave externally as a struct.  #experimental


## the "produce struct class from box" method

so the upstream box might be an arbitrary box subclass.
we, however, will produce an instance of our selfsame ::Struct
subclass here, which mixes-in box reader instance methods.
you then loose whatever fancy crap your box subclass has, which
is probably necessary-esque and fine (you still want to produce
actual struct, don't you? it's basically a multiple inheritence
problem (read: annoying and you would be doing it wrong)).

BUT: when we run filters (like `reduce`-style operations) _on_ the
produced struct that themselves produce new boxes on the other end,
what would be really neat is if those themselves preserved all the
same class associations and `base_init`-style ivars that you would
have gotten had you run the filter on the original box (during the
state it had when you crated the struct).

SO: as such, what we attempt below is to sort of "freeze" the
`base_args` as they stand at the time of struct creation (they
shouldn't be too volotile anyway, as a matter of design) for use
in future result boxes that we create.  BUT ALSO: we need a _slice_
of the base args of the box to init ourself with, as if the box
were definately just a basic formal box. HACKSLUND


## :#hash-risc

currently the hackiest part of this node (maybe) is the fact that we create
a struct class that mixes in the box reader instance methods. those instance
methods rely on there being an instace variable called @hash. in an ordinary
box, the @hash holds the values, but in a struct, the internal ruby struct
holds the values. yet we still want the @hash to be there so we can use our
large assortment of box methods (the whole point to all this):

the solution, of course, is a proxy. we make a proxy object that quacks like
a hash, but attempts to "do the right thing" w/ respect to its host.

this would normally feel really really hacky, except that the way it turns out,
we only need two or three operations on a hash to make the bulk of our box
work. given that there are so few 'API contactpoints' between the box and its
hash already, it seems as though it already has a near perfect design that
lends itself well to this kind of hackery.

so, with a few operations we can implement many box operations:

  ( <hash operation> : <box operations> )
  ( key?             : has? if? )
  ( fetch            : if? each fetch fetch_at_position invert at )
  ( dup              : to_hash )

#todo: `dup` is only used in `to_hash` and so should be reduced out -
unfortunately for that method it doesn't warrant its own hash operation.
