# the actor dream :[#066]

## the idea

this is the new dream of unification.

actor's purpose is to make small classes easy to implement, when that
small class's purpose is to produce a single result (and perhaps numerous
side effects) through an interface that is essentially proc-like, being
called with (a usually nonzero number of) arguments passed typically in
a single positional arglist or [#046] iambic.

that is, an actor has a single point of interface (its call method) and
a single result (the result of the method). whether this call has
side-effects on the actor itself is unknowable and inconsequential.

ideally all actors will be indiscernable from procs, and all procs (by
our defintion here) can be classifed as actors (sidestepping all the other
things you can do with procs, like currying, which we will ignore for now,
but hold that thought..)

this can probably serve as a replacement for every similar library that
came before it that does *not* support meta-properties. as such it is
among the top three most important entries in :+[#mh-053] the parameter
library pantheon (and see "compared to the others" below).

we borrow the term from the 'actor' pattern, to which this is currently
only superficially related, however along the way to its single result,
our actor can emit events to an event receiver if it so desires (simply
by accepting an event receiver as an argument along with the rest).




## the actor's interface at a high (and lofty) level

an actor is the quintessential :#proc-like: typically you "call" it sort of
like you are calling a function (a proc or a method) and it produces one
result (possibly with side-effects).

in fact, often you won't know just by looking at such a "call" whether the
thing being caled is a proc, an actor, or some other "proc-like" entirely;
and often you won't care nor should you. this is the phenomenon of
abstraction at work: abstraction is a machine for optimizing the human's
focus.




## the actor's external interface, theory and practice

every actor's external invocation interface is intentionally a subset of
[#br-001] the way we interact with entites.

(#todo talk about building vs. calling, maybe between actors v.s
entities. this space is evolving presently, specifically we don't know
if we want to support formally the notion of building (but maybe not
executing) an actor.)

...

whereas with a real life proc the two ways you can call it are with

    `[]`

and

    `call`

, an actor is *usually* called with either

    `[]`

or

    `with`

. although we could have just stayed parallel to the proc pattern, the
actor interface decidedly breaks from it in this way because the actor by
design and as a tautological rule accepts arguments that in their surface
form are passed either as "positional" arguments or as an [#046] even
iambic:


    Add_two_numbers_[ 1, 2 ]  # => 3

    Add_two_numbers_.with( :one_number, 1, :another_number, 2 )  # => 3


note that the first form just passes arguments in the familar C-style
syntax, "positionally". the second form uses our kooky (and awesome)
[#046] "iambic" form.

both of these two forms of invocation are available "out of the box" to
every actor because the actor base class defines a `[]` and a `with`
method. whether the arglist should be parsed "positionally" or as an
"even iambic" is determined by whether `[]` or `with` was called
respectively.


### a bit of poka-yoke

this is the reason that in actors we don't simply alias `call` to `[]`:
in practice in our call to procs we often "upgrade" from `[]` to `call`
as soon as our argument list spans multipe lines for reasons of aesthetics
presently hard to explain (#todo).

however as soon as your arglist grows beyond one or two arguments, if
those arguments are positional this call exhibits poor self-documentation
and becomes a smell [#sl-129].

actors are an experimental answer to this that allow for long-ish
argument lists that are still readable (because each argument has a
"name tag" that comes before it). (still the vaild question remains of
how long you should let your formal arglist grow in an actor and in
general.)

so, a call with `[]` (vs. `call` or `with`) works better for single line
calls. when you have many arguments, they both should use name tags and
should span multiple lines. hence, the fact that actors interpret your
arguments positionally with `[]` and iambicly with `with` encourage you
to write more readable code by design (almost like poka-yoke maybe?).




## the actor's inward-facing interface


to the implementor an actor can be imagined as like a struct that has
a single `execute` method. your `execute` method is exemplary of this
idea of :+#hook-out (:#hook-out?): it is something (and the one thing
in this case) that the library can assume you have implemented yourself.

you are *strongly* encouraged to break your `execute` method implementation
down into smaller sub-methods as soon as you require more than a few lines.
this is the main reason we created this: to give you an (almost) wide-open
namespace to make as many private support methods as you need.




## actors compared to the others

see [#mh-053] the comprehensive list of libraries like this.


here is how it compares:

 + unlike [#br-001] the entity library, actors do not currently (and
   probably never will) support meta-properties (like `required` and so
   on). actors embody an intentional simplification of entities.

 + [#mh-061] basic fields will nil out fields for you; this does not.
   however this will probably replace that. (yes: with [#058] methodic
   actors.)




## :#note-80

this is all hugely experimental, but for now actors are assumed to be
named like local procs, that is:

    class Verb_noun_etc_etc__  # ..




## actor patterns :[#045]

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




### the "any result" pattern :[#046]

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

internally use [#C] simple [#bs-015] `ok` chains to drive your flow. set your
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
although [#bs-015] `ok` chains are arguably kind of ugly, the are still better than
every other comparable alternative we have tried in the lengthy history
of this universe.
