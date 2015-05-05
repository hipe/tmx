# the system narrative :[#140]

## :#section-1 introduction

welcome to the headless system node. thie node provides system / environment
reflection and defaults access in a zero-configuration manner, e.g things
like the pathname to a usable cache dir or temp dir, for whatever the
particular system is that we are running on.

it does not have an especially robust or adaptable implementation yet, but
it stands as façade for such a future; and to any extent that it works now
and will work then, clients need be none the wiser.

the whole premise of this node is dubious; but its implementation is so neato
that it makes it worth it. at worst it puts tracking leashes on all of its
uses throughout the system until we figure out what the 'Right Way' is.




## :#note-40

when args are pased and the service isn't available we fail hard by
raising an exception. this is an explanation of why.

when args are passed and the service is available, it is shorthand for
sending those args to the `call` method of the service. it is totally up
to the service what the semantics are of the result value.

in cases where the service isn't available, if we were to result in e.g
`false`, there would be no telling whether that value came from the service
or came as a result of the service not being available. hence, in order
to avoid a potentially catastrophic loss of meaning with the result
value, in cases where args are passed and the service isn't available we
must take more drastic measures than e.g merely resulting in false.

if there is any doubt whether the service will be available check first
by accessing the service itself before using its `call` method.




## :#section-2 introduction to the front client

we implement the methods and services of the "system" through this private
client class because given how bad singletons are for testing and for
sofware design in general, this will get our code from both sides used to
the idea of accessing and delivering these values through some sort of
agent, albeit one that perhaps now in its current form is not much
different than a singleton.



## :#section-3 introduction to the defaults node

this is a higher-level service that for many of its properties relies on
other lower-level services and maps certain of their pathname
properties in some way. at once point we said about this node:

this is the ugliest node of the whole thing but at least it's all in one
place. (it's not ugly from an implementation perspective. it's beautiful
from that perspective. its flawless beauty transcends any flaw of character
it may have.)


### :#storypoint-5 (the memoized proc iambic array)

(#in-situ for now.)


### :#storypoint-10 (field)

this node it is #experimental. it is for experimentally caching things to
the filesystem when running in a production-like context: it should only
be used with the utmost OCD-fueled hyper-extreme caution and over-engineering
you can muster, because nothing puts a turd in your easter basket worse than
an epic bughunt caused by a stale cache save for actually experiencing that.



## :#section-4 the IO node

if ever we find that we are trying to run in an architectural context
where we don't have access to all three of the "standard streams"[1][1],
we want to have dependency leashes all going back to the same corral.
also it's simply always bad to put globals in your code no matter what.

for the sake of being deterministic and a bit more robust, we assign the
three streams to closure variables when this file first loads, in case some
wild script goes changing the values. this is another reason not to access
them directly. also, what I just said is API private.

we gave the methods ultra-futureproof, super verbose names. the method name
expresses the arity, the semantics, and the shape (in order) so hopefully
these names can resist seas of change for a long while.

the IO singleton is also a module for now: although we are not yet using it
as a module currently, we might one day.



[1]: http://wikipedia.com/Standard_streams  # #todo
