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



## :#section-2 introduction to the client

we implement the methods and services of the "system" through this private
client class because given how bad singletons are for testing and for
sofware design in general, this will get our code from both sides used to
the idea of accessing and delivering these values through some sort of
agent.



## :#section-3 introduction to the defaults node

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
where we don't have access to all three of the _Standard_streams_, we want
to have dependency leashes all going back to the same corral. also it's
simply always bad to put globals in your code no matter what.

for the sake of being deterministic and a bit more robust, we assign the
three streams to closure variables when this file first loads, in case some
wild script goes changing the values. this is another reason not to access
them directly. also, what I just said is API private.

we gave the methods ultra-futureproof, super verbose names. the method name
expresses the arity, the semantics, and the shape (in order) so hopefully
these names can resist seas of change for a long while.

the IO singleton is also a module for now: although we are not yet using it
as a module currently, we very well might one day.
