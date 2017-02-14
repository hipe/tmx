# the entity enhancement narrative :[#001]

## introduction

the "entity" facility continues a [#fi-001] long line of entity- and
property-modeling libraries. of them all this is the most overwrought,
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




## #explanation-235

using a particular name that is globally universal and fixed,
we set within the client module (which is an "extmod" we are
mutating) a reference to itself..

what is in the ivar `@client` is actually a new-ish "entity
enhancer module" ("extmod"). although it is the client of this
session, it will eventually have clients of its own that it
enhances.

if we set a reference to itself in itself, actual clients
of this extmod will be able to reference the most recent
extmod they ehanced themselves with by using this const.

the reason its name is in scream case and not module case is
because although the value of the const is a module, the module
does not "live" in this location; it is just a reference to
a module that lives somewhere else. we use "scream case" for
constants that hold "values", and in this case the module
is treated as a value. this way, we know not to go looking
for the "home" in that location for the module in question.




## :#explanation-290

the below methods are defined as public or private based on the
emergent needs of projects in the wild, which is kind of nasty.
an alternative is to check for the defined-ness under both
classifications per method, or just insist that it all be public.

the only method that we trump is the one used as a null hook-in
(stub) in the wild - `properties`. for the rest, we check for
collision first before defining them these complex reasons:

1) the overarching tactical objective is not to clutter the client
   ancestorchain space or method namespace. the primary utility
   of the entity library is to create the "properties" structure
   (perhaps by defining and using metaproperties). as such, we
   accomplish this by writing as few methods is practical to do
   so *directly* onto the client, rather than adding to the client's
   ancestor chain:

   in the wild what often happens is this: (let "client" mean an
   application-specific action class or model class.) one
   business-semi-specific "extmod" is created, and some (but not all)
   client classes are enhanced with this extmod, as well as perhaps adding
   their own properties and maybe meta-properties too. those clients that
   need nothing to do with this entity library or the extmod are left
   alone, yet they can share a common application-specific base class
   with the other clients.

2) in the typical OOP design that might take place in the host platform,
   a client class might "pull in" one "mixin module" and then another
   one after it, expecting correctly that this second module will
   effectively "override" methods in the first module, because the
   second module ends up closer to the subject on the ancestor chain
   than the first module. furthermore the client class itself may define
   methods that effectively override methods in this second module.

   because our overarchign design axiom here is that of minimizing
   activity on the ancestor chain of clients, we do not rely on the
   above model to achieve this described effect of inheritence with
   overriding. instead we attempt to accomplish a similar effect through
   this means:

   our hand-written mechanics add methods *directly* the client
   *passively*. this means that if a client defines her own this or that
   method before we get there, we won't add our version. but if the client
   has not yet defined the method, it gets *its own* definition of that
   method from us.

   (note that one cost of this technique is that the client-defined
   method cannot "call up" to one of our definitions with `super`,
   because our definition won't be anywhere on the ancestor chain.
   however, our methods are always reachable by some means because
   ultimately they are all individually defined as procs first.)

   the end result of all this (to put a finer point on something hinted
   at in (1)) is this: the client application can write one base class to
   rule them all. some child classes of this base class may not need the
   entity library, and those ones will not get their ancestor chain
   "polluted" by anything related to the entity lib. those that *do* will
   get their chain polluted by *only* the application-specific extmod
   defined by the client (human).




## a "clever" parsing experiment  (#note-185, also was #note-330)

interstingly, this current form of the method (that may look like
function soup) buries a previous form of the same thing that had
a dedicated class for it (find it thru the tombstone). usually
this goes in the other direction, with the functional soup getting
re-written as class-based.

the reason this is so is a mystery to us. during the re-write, we
did this in a blind, black-box, outside-in fashion (not looking at
the previous implementation code, only using the previous test files.)
so although whatever the reason was to do it functionally eludes us,
we did it with an "intentional feeling".

what this does is very interesting to us: it manages a collection
of (currently 3) "parsers" that we can think of as "nonterminals"
in our grammar.

(for aid in understanding this, they are the NT's for:

  • a property or metaproperty "phrase" (note that such
    a phrase does not necessarily start with one of these
    two keywords.)

  • a phrase whose "head keyword" is one of our hard-coded
    builtin phrases implemented in this file

  • one of any of the "ad hoc processors" defined by the user
)

the really fun part of "entity" is that "the grammar" gets mutated
by the user and then is available immediately for use. this process
is not discrete but continuous: part of the parser's purpose is to
support the modification of its own syntax. but that is perhaps not
relevant..

so the interesting mechanic here is something like this: each of
our three "nonterminals" starts out in a certain order. (we call this
array of symbols "optimism", because we might call this "optimistic"
parsing.) (no, wait: we were calling it "adaptive".)

with the input stream in its current state, we will try each one of
these nonterminals in order. if we don't find one, we have failed to
parse and we are done. but if we do find one:

if the one we found was the first nonterminal in this list (of
*mutable* order) of nonterminals, then we either loop back to try
all the nonterminals again, or finish based on whether there are any
more tokens of input.

but if the one we found was a *non-first* item in the mutable list
of nonterminals, *we move it to the front*. the other items in the
list stay in the same order with respect to each other.

immediately, this has two interesting ramifications:

1) hypothetically this grammar-ish is self-optimising:  whatever
nonterminals occur most frequently float to the front of the mutable
list, and are tried earliest as a nonterminal is searched for.

2) this opens up the possibility of some very non-determinsitic
and whacky behavior, which we will ignore the idea of for now because
we haven't *yet* run into problems yet (although we can certainly
imagine some..)

(:+#tombstone: the previous explanation for this, almost as good)

certainly for certain grammars and certain inputs this will slow
the parse down more than if the parser were not "adaptive": this
is intended for inputs that are written in "sections". when each
next section is reached the parser puts the relevant nonterminal
at the front.

the reason we made this "adaptive" (er..) adaptation was this:
we tend to write our entities in sections, and we want the parsing
of them to be fast. also it is a fun experiment in general.




## :#explanation-735

the properties box is used for reading *and* writing (i.e storage and
retrieval) of the frozen property objects, however it does not hold them
directly. we leverage the platform's existing inheritence system to
achieve reuse of these frozen properties across definition nodes (be
they module or class):

when a particular property object is needed, it is retrieved by calling
a singlton method of an appropriately derived name on that particular
node. (this description applies to "static" formal property sets, not
dynamic ones.)

to allow the above, the property box only holds symbolic references
(that is, symbols) to these properties: the keys of the box are the plain,
normal, "local" symbol names of the properties. the values are the special
"shibboleth" method name constructed to access that property.

in the cases where the node is a class, the thing that fulfills read
requests for the properties is the class itself. the thing that gets
methods added to it when properties are added is the class's singleton
class.

in the cases where the node is a module, it's kind of tricky: this
"extension" module will share its properties to clients by the use of a
`Module_Methods` module it carries; so this is the thing that gets
written to when properties are added. the extension module itself (as a
receptacle for methods) will hold only ad-hoc methods created by the
human.

*retrieving* the properties *directly from* the extension module, on the
other hand, is a service that is a bit peripheral to an extension
module's primary purpose. (normally the extension module enhances a
client class, and it is the the class that is used to retrieve the
properties.) but to allow for this to happen, we create a special
singleton object (that we happen to use a module for so it can report
its name) for this purpose. this module has in its *singleton class*
ancestor chain the `Module_Methods` module that holds this extension
module's properties. (we could just have used the extmod itself to be
this receptacle, but we want to enforce with our design this separation
of concerns.) whew!




## :#stowaway-1 ( in [br] "core.rb" )

although this method is expected only to be needed by nodes that
have formals, for complex reasons it is most convenient to define
this base implementation here. this way, a client application can
define its own action or model base class descended from ours and
define its own default implementation of this. then when its interface
nodes (models and actions) either do or don't use an "extmod"
enhancement, they will use this correct implementation without
having to worry about the extmod's form clobbering it (if it were
the case that we let this method "live" in the extmods, which is
otherwise a reasonable first guess for where such a thing should go,
because the entity lib's central purpose is for working with properties.)

the default is to raise this as an exception because it makes
the error much easier to trace in the cases where your action is
being used as an internal API call. this is partly why we put the onus
on the front client to ensure required'ness of arguments, because it
is better suited to report this condition appropriately than we are at
this level.




_

( :+#tombstone: interesting notes about consts vs. ivars, omitted per
relevance)
