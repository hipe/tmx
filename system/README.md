# the skylab "system" sidesystem :[#001]

## objective & scope

## :#section-1 introduction

encapsulates access to basic and not-no-basic facilities of the
underlying system. attempts to do so in a zero-configuration manner.
for example it attempts to produce a path to a usable cache or temp dir
for whatever particular system we are running on. it wraps basic
filesystem access so such things can be mocked. it has wrappers for UNIX
utilities like `find` and `grep`.

it does not have an especially robust or adaptable implementation yet, but
it stands as façade for such a future; and to any extent that it works now
and will work then, clients need be none the wiser.

(historical note: this was extracted from [hl] and promoted into its own
sidesystem. before it became a sidesystem, we had once said:)

the whole premise of this node is dubious; but its implementation is so neato
that it makes it worth it. at worst it puts tracking leashes on all of its
uses throughout the system until we figure out what the 'Right Way' is.




## justification and role (introduction to the "interaction idiom")

this is meant to replace what in more one-off type implementations is
achieved through "backticks" calls (like `grep foo .`) AND EVEN the
types calls commonly used to interact with the filesystem, like `open`
etc.

this "interaction idiom" is intended to give *your* system "better"
design in a "poka-yoke" manner, by forcing you to interact with "external
services" though a controlled conduit as opposed to accessing such
services through a language feature (backticks) or corelib (e.g Kernel)
methods like `open`

yes, under our idiom, even the filesystem is modeled as an "external
service", for what else is it but a storage and retrieval system that
is very well suited for certain kinds of data?


### the pro's

  • it makes you think about what external dependencies your app is
    incurring by making your code exhibit those dependencies explicitly
    (through calls to `[sy].services.foo` etc). the hope is it makes
    your project more portable to other environments and even platforms
    by modularizing and compartmentalizing the system dependencies it
    has.

  • accessing system services through "system conduits" makes testing
    easier, sometimes significantly so. (for example, covering whether
    your system has a "/tmp" directory. the solutions of "not testing
    for this at all" and "testing for this without mocking it" both
    feel awful.)

### the con's

  • you have to buy-in to our dogma with your code. typically it doesn't
    come at a huge cost in codesize.




## :#section-2 introduction to the front client

the main utility (as in value) of this sidesystem is in its "services"
interface object. each of its methods correspond to the services that
are supposedly availble on this system. that is all. note how simple
that is.

   • this services interface object is effectively (and actually) a
     singleton object. there are good arguments against singletons
     in general: they are bad for testing and they are bad for system
     design in general. however, we procede to use the singleton with
     the justification that

     * we have not yet come up with a better design. suggestions
       welcome.

     * this "interface object" is for accessing resources on "the
       system". the interaction idioms that this facility replaces are
       things like calling system calls with backticks,

we implement the methods and services of the "system" through this private
client class because given how bad singletons are for testing and for
sofware design in general, this will get our code from both sides used to
the idea of accessing and delivering these values through some sort of
agent, albeit one that perhaps now in its current form is not much
different than a singleton.

   • one day we would like a reflection API that lets clients check
     first (or with a `fetch`-like method) whether a service has been
     found to be available on the system. this interface object is not
     that. its public method namespace is #cordoned-off, reserved
     strictly for the names of available services.

   • such a reflection API is not yet implemented, although we are
     leaving room for it conceptually, in our minds. clients that call
     services without checking if they are loaded do so at their own
     cost with the possibility for an *undefined* exception being
     raised in such cases.

     whether to raise e.g NoMethodError or SystemCallError in such cases
     is a design choice up to us, and should *not* be coded around by the
     client! this will remain undefined. the right way to handle such
     a case is for exaple to use

         Top.service.fetch :grep

     instead of the easier to read

         Top.services.grep

     IFF the client want to be more environmentally agnostic. again this
     is not yet implemented, as it would be premature to implement this
     yet, given the scope of the project at this phase.





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
