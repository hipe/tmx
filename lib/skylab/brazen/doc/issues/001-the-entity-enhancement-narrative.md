# the entity enhancement narrative :[#001]

## introduction

the "entity" facility continues a [#mh-053] long line of entity- and
property-modelig libraries. of them all this is the most overwrought,
and as this is written is undergoing its first overhaul.

once this overhaul is complete (probably by the time you read this), it
is guaranteed to be modular and snappy.

the big features that this boasts over its both its predecessors and
those of its successors that became upstream dependees is:


• fully customizable iambic DSL that can modify itself thru the use of
  "ad-hoc processors" ("non-terminal symbols").

• the ability to produce extension modules from your custom DSL, so that
  you can enhance classes using your DSL without needing to sub-class.

• designed from its inception to model business entities and their
  actions through the use of meta-properties.

• perhaps the only remaining library under active development that
  supports a DSL for meta-properties.

• wherever possible builds and reuses from the other 2 popular nodes
  from the list of libraries.



## on parsing (new for the second edition)  (#note-115)

we build a queue of nonterminal parsers each of whose children will be
used in order in attempt to parse the symbol upstream in its current
state.

any ad-hoc parsers node will go first in this queue, giving ad-hoc
parsers the ability to override any other syntax that comes from us
out-of-the-box or otherwise further down on the queue.

we then place the property-related nonterminal, giving *it* the ability
(with the metaproperties etc of the property class) to override the
syntax further down the queue from *here*.

then finally we place the edit session itself as a nonterminal parser in
this queue which will catch the limited number of symbols that we parse
out of the box.




## explorations on re-use across modules :#note-320

this was distilled from the following pattern: we have an object that if
used for the purposes of reading (that is, the constituency of the object
itself will not mutate), the object can be accessed in an inherited way:
the different modules in a module graph may all access the same object,
and do not need (nor should not have) their own deep copies.



### consts vs. module methods

(quick note on local jargon: "client module" is the thing doing the
re-using, "container obect" is the thing being re-used.)

although it may be a tautology, it it worth stating it explicitly here:
remember that const assignments themselves are immutable: once we have
assigned one object to one const in one module, that const in that
module may never point to anything else. althogh the constituency of the
object itself may be mutable, the identity of the object that the const
points to is not.

const assignments are visible to client modules in ways that methods are
not: within one "container object" module we can encapsulate both instance
methods and consts, and the client module can re-use the assets of these
two disparate namespaces by accessing only one container object; as
opposed to getting class methods to inherit, which is accomplished by
drawing from yet another container objects (a module methods module,
usually in addition to an instance methods module); or by subclassing,
of which we are limited to drawing from only one such structure.

for now, the benefits of using consts to store reusable values outweight
the cost of having the object's identity be immutable (for the
containing module). in fact this characteristic has other benefits:
knowing that the identity is immuable means we may memoize safely the
object's identity elsewhere.

using a const and not a method to access values like these makes it more
poka-yoke and self-documenting.



### ivars and consts

so if the object is to be read only then we use const name lookup.
however, if that object is to be mutated, that object must "belong to"
whatever module it is appropriate to be owning that object for the
change being made.

for such cases we use an ivar to store this writable form of the object
in the module. an ivar "lookup" does not actually look up anything: it
either is set for that module or it isn't; the ancestors don't come in
to play.
