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
effects).

we borrow the term from the 'actor' pattern, to which this is currently
only superficially related, however along the way our actor is expected
to emit events to an event receiver if it so desires.

it can probably serve as a replacement for every similar library that
came before it that does *not* support meta-properties


here is how it compares:

 + unlike [#br-001] the entity library, actors do not currently (and
   probably never will) support meta-properties (like `required` and so
   on). actors embody an intentional simplification of entities.

 + [#mh-061] basic fields will nil out fields for you; this does not.
   however this will probably replace that.



## :#note-70

the use of the word `with` at the end of a method name is reserved
exclusively for methods that take as arguments literal iambics.
typically the method named `with` itself (as a bare word and not part of
the larger method name)
either mutates the receiver or dupes, mutates and freezes; resulting in
either self or the dup respectivey. in this case the result is the
result of the actor's execution. we make this exception from the
convention because it reads better, given that actors are recommended to
be named after verb phrases.



## :#note-80

this is all hugely experimental, but for now actors are assumed to be
named like local procs, that is:

    class Verb_noun_etc_etc__  # ..




## actor patterns :[#A]

sometimes only a name and some documentation makes the difference
between a perceived smell and a local design pattern. we have
accidentally begun to refactor-out some techniques that were at first
perceived as a smell until we got halfway done and then only understood
the deeper meaning behind the technique once our attempt at refactor
failed miserably. the below patterns, then, are an attempt at bridging
that gap by turning each of these "somethings" into some "a thing".

we are presenting each pattern in terms of both its behavior and
recommended patterns for implementation; but keep in mind these are
related but separate points.




### the "any result" pattern :[#B]

if you specify (or are specified) that you follow the "any result"
pattern then you must result in either your payload or the result of
the last `receive_event` message you sent to your event receiver. this
way in cases where you cannot produce your mission payload for whatever
reason your caller herself can determine your result which can be
convenient.

`Hash`'s `fetch` method in its use of blocks typifies exactly the
pattern we are describing:


    x = some_hash.fetch some_key { some_other_value }


if `some_hash` does't have `some_key`, `some_other_value` is the result.


#### implementation pattern

internally use [#C] simple `ok` chains to drive your flow. set your
`@result` when either you send an event or you get to your mission
payload endpoint. in either case your `execute` (or tributary) is an
`ok` chain that always results in `@result`.


##### advantages:

your result is only set when (presumably) it is complete. depending on
your platform you can get warnngs to issue if your flow didn't succeed
in setting your result.


##### disadvantages / gotcha's:

if the caller is unaware this pattern is being employed she can
accidentally break logic flow severely by mistakenly assuming, for
example, that some truish value is a valid mission payload when in fact
it is some random true-ish final result from an event handler callback.

and for a note about our suggested implementation,
although `ok` chains are arguably kind of ugly, the are still better than
every other comparable alternative we have tried in the lengthy history
of this universe.
