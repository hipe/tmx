# name conventions for functions and methods :[#05]


## introduction


we say "function" to give these ideas a bit of platform independence;
however in the context of the current host platform, when we say "function"
we always mean "proc" or proc-like.

this is a re-creation of a document lost in the [#084] fire. it will be
better this time.


## the list of conventional method prefixes/suffixes/names.. :[#103]

..and an introduction to their semantics.

+ `build_` (and often `bld_` per [#119]) - result is a new instance of a
  class (either library, stdlib or corelib) that is not one of the
  classes described by `get_` below. the object may or may not be
  initialized in some special way as decribed by the method name. this
  method must have no side-effects. (oops also see [#154] for the same
  thing written 10 months prior)

+ `calculate_` - method must take a block. result of method block must be the
  result of the call to this method. the block will executed in the
  context of some special agent and *not* that of the caller; as such
  this type of method is intended for an explicitly contained employment
  of some particular DSL or another. this method *may* have side effects.
  [#141] expression agents are exemplary of this.

+ `execute` has a strict API meaning for a lot of our libraries as the
  one #hook-out method the client must supply. it must take no
  arguments. [#cb-042] actors exemplify these semantics, as well as many
  of the base-classes called something like "action" in many of our
  frameworks.

+ `[_]from[_]` - this meaning is explicitly not defined conventionally.
  use "from" how you like, but do not use it if you can use `via`.

+ `get_` - result is the result object of having allocated new memory
  for and initializing an object that is either of a native "primitive
  data structure or type" or a ubiquitous low-level utilty class (scan,
  box, hash, array etc). see [#094] dedicated section on this. this method
  must have no side-effects.

+ `flush` is our "go-to" name for something that cannot fail and
  produces the "payload result" of the [#cb-042], "actor-ish" perhaps
  with some irreversable internal side-effects that make this method not
  idempotent (but perhaps not).

+ `init_` has at least two distinct meanings: 1) as `init` it is a
  specialized initializer when it is not practical or possible to use
  `initialize` (e.g a `dup`ed object that gets initialized by a
  parent. `init_copy` is a suggested default name for this (to
  compliment the platform-recognized `initialize_copy`). 2) `init_foo`
  should typically init the ivar `@foo` in a way that cannot fail. if it
  may fail (as would be evinced by a result value) use [#154] `resolve_`.
  `init_ivars` is a popular method name employed in [#cb-042] actors for
  initting those ivars that cannot in the current state fail to be
  initted.

+ `produce_`, `_produce[_]` - result is the subject object as described
  by the rest of the method name. whether or not new memory is being
  allocated for this object is explicitly undefined (contrast with `build_`
  and `get_`). sometimes we use this when we know that our result is a
  memoized instance but want the ability to change that decision in the
  future.

+ `resolve_` - has a dedicated [#154] document that needs a rewrite.

+ `via_` will one day have its own section #todo

+ `_with` - must have no side-effects on the receiver.
  (use the never-been-used-before `_who_has` to mutate the receiver.)

+ `work` is our "go-to" name for the interesting body of ..er.. work
  that is done in an [#cb-042] actor's `execute` methods after the
  un-interesting initting and validation is performed. a method with
  this bareword name must not accept any arguments. this is a lazy method
  name - it should only be used the behavior that occurs in the method
  is exactly that as described by the name of the containing class.

+ `to_`, `_to_` - the second form is explicitly not defined conventionally
  here.  use it as you would like to naturally. (but use `via` instead if
  you can, because whereas `bar_via_foo()` is unambiguous,
  `foo_to_bar` is ambiguous with respect to whether the argument
  is `foo`, `bar`, or both.

  the first form (`to_`) is used in the platform idiomatic way, e.g
  `to_a` etc.  `to_scan` is a popular one in this universe (note it used
   to be `get_scan`, i.e uses the same semantics as `get_`).





### the `get_` prefix semantics as a nod to an ObjC convention :[#094]

it is perhaps a misunderstanding of the convention, but we base these
semantics off of something we read in the hilleglas book (#todo)




## the method naming shibbloleth :[#119]

this is a bit of a contentious pattern, but one we find utility from:
for certain kinds of classes/modules, we may abbreviate certain words of
certain of their method names in a regular way. to absolutely *anyone*
who hasn't read this, the effect may just appear as messy and erratic,
but there is in fact an a simple set of rules governing this obscure
shorthand. this section describes both the pattern behind this chaos
and the utility of it.

in summary, the pattern has to do with visibility and at some level is
comparable to the [#079] three levels of visibility as expressed by
trailing underscores of const names. what we mean by "visiblity" and how
this may be different than the visibility you are familiar with will be
explained below.

the fundamental rubric is this: if a method name has one or more words
that is abbreviated (not including idiomatic or business acronyms like
"IO", "HTTP" etc), then this abbreviation indicates that the method is
variously API private or API protected in some what (what these mean is
explained below).

conjunctive words (whether conventional themselves or not) like "and",
"via", "from" are never abbreviated. abbreviation of a word never
removes the first letter of the word. acronyms are never further
abbreviated.

first, we will describe the three patterns of abbreviation, then we will
describe what these respective patterns mean.

consider a method whose would-be name is this:

    resolve_upstream_IO

the "stem words" that make up this method name are these three:

    resolve upstream IO

we cannot abbreviate "IO" any further because it is already an acronym.
but we can abbreviate the other two:

    resolve -> rslv

    upstream -> upstrm

note that to abbreviate a word typically means to remove the non-initial
vowels from it.

so if we were to abbreviate this method name "all the way" it would look
like this:

    resolve_upstream_IO  # before
    rslv_upstrm_IO       # after

but we don't typically do that. what we *do* do sometimes is this:


### we might abbreviate some part of the *first half* of the method name:


                      `resolve_upstream_IO`
                         |              \
                      (first half)    (second half)
                         |                \
                         V                 \
                      `resolve`         `upstream` `IO`
                         |                  |
                         V                  |
                      (abbreviated)         |
                         |                  |
                         V                  /
                       `rslv`              /
                         |                /
                         V               V
                         `rslv_upstream_IO`


### *or* we might abbreviate some part of the *second* half:


                      `resolve_upstream_IO`
                         |              \
                      (first half)    (second half)
                         |                \
                         V                 \
                      `resolve`         `upstream` `IO`
                         |                  |
                         |                  |
                         |             (abbreviated)
                         |                  |
                         |                  V
                         |             `upstrm` `IO`
                         |                /
                         V               V
                         `resolve_upstrm_IO`


### *or* (for completeness) no abbreviation at all:


                      `resolve_upstream_IO`
                         |              \
                      (first half)    (second half)
                         |               |
                         V               V
                       `resolve_upstream_IO`

if the method name was abbreviated in the *first* half, it means that
this method is "API private" (explained below). if the method name is
abbreviated in the second half, it means this method is "API protected"
explained below.

(mnemonic: if the hard to read part is at the beginning of the method,
it says "turn back now", i.e it is more private than if the hard-to-read
part is at the end.)

if the method is not abbreviated at all, it *may* mean that the method
is part of this node's public API, depending on what kind of node it is:

if a method (anywhere in our universe) has one or more abbrevable words
and that method does not employ the abbreviated forms of the words, this
method is part of the node's public API if (not IFF) this same node
employs one or more of other categories of visibility (i.e `protected`
and/or `private`) elsewhere in the node as evinced by the presence of
abbreviations of some of the words of the method names.

conversely, **abbreviations may not be used anywhere in the method
names of this universe unless they are in exhibition of the semantics of
the conventions described in this document**.

to break up a method name into "halves" like this requires that there
exist more than one "abbrevable" [2][2] word in the method name. given
the surface form of a method name having undergone this transformation,
to decode whether or not the abbreviation took place in the first or
second half will probably require some apriori knowledge: you may have
to know (or be able to infer) what the "stem words" were in the first
place, and which of the words are un-abbreviated not because of our
"first-half/last-half" dichotomy, but because they are unabbrevable.

for methods with more than two abbrevable words, it is recommended
that you only abbreviate at most one word (unless you are being
intentionally obscure perhaps for something you expect to be a
shortlived or an especially volatile hack that should be cleaned up for
"production"). which word you chose to abbreviate must be determined by
the above rules: the word should be either the first or last
abbrevable word, and which it is determines whether it indicated a
private or protected method with respect to the node's API.

a method with only one abbrevable word may not employ this convention
unless the method has more than one word and the abbrevable word falls
cleary on one "half" or the other and it falls on the correct half that
expresses the level of visibility the method is designed with.

a method with zero abbrevable words cannot (of course) employ this
convention at all, but by a proof to be offered in the future (#todo) we
will demonstrate how any "short" method name can be expanded to one
sufficiently long enough to employ this convention.

as for what these levels of privacy actually mean, this is the subject
of the following section.




## what do "API public", "API protected" and "API private" mean?

(spoiler alert for the eager and precocious: these three levels of
visibiy have semantics similar but not the same to the three levels of
visibility decribed by [#079] the trailing underscore convention for
const names.)

recall from [#094] that when we say "node" in the context of the
native platform usually (but not always) mean "module" (e.g "class").

an "API public" method is part of the "public API" of the node as is
defined by semantic versioning [1][1]. note that, perhaps confusingly,
this has nothing to do with the levels of method visibility as is
granted by the `protected` and `private` keywords of the host language:

a method can certainly be part of a node's public API and still be
private, for example. this is exactly because classes can be sub-
classed, and modules can be mixed in. when an API class is subclassed
or an API module mixed-in, the client node needs to know whether the
private and protected methods of that API node are stable and reliably
free from behavioral change given this version of the API, just as much
as it would be with a public method (but broadly this hits on what
we now consider a :+#smell discussed #here).

"API protected" and "API private" methods are decidedly outside of the
domain of semantic versioning: if a method is "API private" it means
that that method can be called by the defining node *only*: it can be
known about and called from only the class *itself* or module *itself*
that defined it (and *not* even subclasses of that class!).

if a method is "API protected" it means that that method can only be
known about from inside of the "sidesystem" (but we may change this to
"library" if we ever define that formally.)




## the smell of the shibboleth :#here

we employ this convention because in the short-term it is valuable to
do so: when we see what looks like an API-private method, we know that we
must not call it if we are outside of the node, and that if we are inside
the node (refactoring/debugging/featuring it) we are allowed to change
its signature, its name, or even delete it altogether (and the same
kind of thing if it is a protected method, only with its broader scope).

in practice this has proven compellingly valuable during refactoring - we
know immediately by looking at a method (either definition or call) what
its API scope is and accordingly how much cost will be incurred (roughly)
if we try and change it.

however, (and we aren't sure yet), this entire name convention may just
be a bandaid over a deeper problem for which there is a simpler
solution: in short the solution may be smaller nodes (classes and
modules). [#cb-042] actors have proven useful to this end. the more we
employ small actors ,n,n






## references

[1]: http://semver.org
[2] : "abbrevable" is an abbreviation of "abbreviable" which is an
     abbreviation of "abbreviatable", which is a neologism meaning "a
     word that can be abbreviated by the rules described herein." we,
     like the general public, will not use these terms outside of this
     document.
