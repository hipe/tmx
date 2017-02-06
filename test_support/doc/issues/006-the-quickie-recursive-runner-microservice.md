# the quickie recursive runner microservice :[#006]

## objective & scope

in spirit, the quickie "recursive runner" occupies a middle-ground between
the lightweight, simple quickie "onefile" featureset and full-blown
rspec. as with the quickie "onefile", the subject does not facilitate any
test-language features not already supported by rspec; but this is not to
say that the subject is simply a functional subset of rspec. on the
contrary, our plugin architecture has plugins that effect test-running
features not available in rspec (while still running tests that adhere
to the rspec-compatability rule); discussed #here.




## functional context

(EDIT: something something "the affectionately named "slowie"")




## architecture


"recursive runner" is a experiment that asks: can we add features
to quickie without feeling like we are bogging it down? the answer appears
to be "yes". the subject is implemented as a set of plugins. (EDIT)




## no plugin base class?

certainly not. we avoid plugin base classes because in part they encourage
hard-to-decipher, too-much-magic plugins. also they dictate implementation
detail, which is overreach for a plugin architecture to do.

rather, every plugin "front" class must follow a simple interface, akin
to the spirit of [#ac-001] "autonomous components".





## implementation notes/developer notes

### microphilosophy by way of justifying the subject module :[#here.A]

how plugins are meant to communicate back to the "mothership" is not
is not dictated by our remote plugin library. (this is why the library
is called a "toolkit" and not a "framework".)

(a brief ponderance on semantics: at the moment, by "mothership" we refer
to *the* microservice invocation instance. if we wanted to be clear at the
cost of brevity, we would call it a "shared datapoint store", through which
plugins can effectively pass data to one another without knowing that is
what they are doing. since this "mothership" also drives the "scheduling"
(using a remote library) and "scheduler" is such a short and familar
concept, for now we'll use this label "scheduler" as an umbrella term for
the object responsible for all of these concerns because *for now* it is all
the same object; but to be sure this is subject to change, because already
it makes it sound like a violation of the single responsibility principle.)

("synchronizer" is another option.)

for a plugin architecture to do anything interesting there will have to
be some degree of coupling between the plugins and the scheduler.
(really, this is what a "plugin architecture" is, is a specification of
that coupling.)

however in this project we want to achieve a degree of de-coupling not
realized in its former incarnation (and other plugin architectures like
it in this universe).

a good degree of useful coupling is achieved by the coordination and
scheduling that comes from the "eventpoint graph" [#here.X] but as we
(EDIT: the above topic needs its own section, then reference it here)
said, that mechanism does not dictate how plugins communicate back to
the scheduler.

now, every plugin instance when it is constructed has the option of
getting a handle on the scheduler itself, which is available by
yielding the block passed to the plugin's constructor.

knowing this, we could simply expose a list of callback-type methods
on the scheduler, one method for every kind of thing we need to get
back from the plugins. as the particular plugin finishes building some
"datapoint" to be used by the broader system, it could send that object
to the scheduler through such callbacks.

in fact, that is exactly what we did in the previous incarnation of this
system and its forebears. (indeed we are sunsetting such code in this
selfsame commit #tombstone-A.) but we don't like this technique because:

  - it feels like a tight coupling between plugin and scheduler

  - this interface enforces no implicit limit on how many times an
    individual plugin can call such a method. to accomplish "write only
    once" requires something like hand-written mutexes or some DSL
    to write and remember.

  - the scheduler ends up with a large collection of such methods,
    that can feel unweildy.

in lieu of this, we are experimentally offering this subject module,
which is a small set of simple structures that the plugin must (typically)
use to get data ("datapoints") back to the scheduler.

this simple interface convention exploits a fundamental property of
methods (and more generally functions): they can have infinite side-
effects but only one result. by encouraging plugins to communicate their
useful product through the use of a simple response structure, we achieve
an implicit enforcement that the plugin's interesting product can be
encapsulated into a single (frozen, even) structure; which avoids a lot
of the problems discussed above without creating new ones.




## document meta

  - :#tombstone-A referenced above.
