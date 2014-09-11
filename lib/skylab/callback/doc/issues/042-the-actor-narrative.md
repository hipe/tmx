# the actor dream :[#066]

## the idea

this is the new dream of unification.




## actors compared to the others

see [#mh-053] the comprehensive list of libraries like this.

an actor is like a struct that is assumed to have a single `execute`
method. its DSL is intentionally made to be a subset of the syntax for
[#br-001] the entity library.

its purpose is to make small classes easy to implement, when that small
class's goal is to produce a single result (and perhaps numerous side
effects)

we borrow the term from the 'actor' pattern, to which this is currently
only superficially related.


it can probably serve as a replacement for every similar library that
came before it that does *not* support meta-properties


here is how it compares:

 + unlike [#br-001] the entity library, actors do not currently (and
   probably never will) support meta-properties (like `required` and so
   on). actors embody an intentional simplification of entities.

 + [#mh-061] basic fields will nil out fields for you; this does not.
   however this will probably replace that




## :#note-70

the use of the word `with` at the end of a method name is reserved
exclusively for methods that take as arguments literal iambics.
typically the method named `with` itself (with nothing else before it)
either mutates the receiver or dupes, mutates and freezes; resulting in
either self or the dup respectivey. in this case the result is the
result of the actor's execution. we make this exception from the
convention because it reads better, given that actors are recommended to
be named after verb phrases.



## :#note-80

this is all hugely experimental, but for now actors are assumed to be
named like local procs, that is:

    class Verb_noun_etc_etc__  # ..
