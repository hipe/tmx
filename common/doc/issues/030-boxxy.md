# boxxy

## overview: synopsis, scope, caveats & alternatives

boxxy's primary provision is to "augment" the real-life `constants`
of any participating module with the "probable" constants that can be
inferred from a directory listing for the directory (folder) corresponding
to the participating module.

this lets clients reflect on the constants (and so assets) that exist
"probably" under a module without having to load every asset, with the
caveats that accompany this inference.

beyond just this primary provision, some clients may leverage the subject
for its reflection API alone. others may want to use it because it can
reflect on stowaways as well as the filesystem and already loaded assets.

whatever it's used for, the subject's primary provisions let the client's
client (sic) hypothetically interact with the participating module in an
ordinary way, ignorant of this underlying hack. (i.e autoloading adds
magic to `const_missing`; and the subject hooks into that magic (A) and
(B) adds magic to `constants` as well.)

and there is now the "operator branch" underlying interface (and
implementation) that is now exposed to access facility-specific features.

there is, however, an inherent problem in the primary provision of the
subject. this stems from what is described at [#024.3], that boxxy may infer
consts that are not accurate, based on things like (A) if any of the involved
consts have runs of all uppercase letters and (B) your naming conventions
more generally. (i.e we cannot know that "stay-out-my-mans-dms.rb" has
the const `StAy_oUT_My_MaNs_DMs` until we load the file.)

some solutions to problems like these are described [#here.c] below.

there are also other more modern attempts to provide behavior like this
in the [#ze-051] strain of operator branches (which the subject has now
recently joined). (look at those dealing with the filesystem.)
these other approaches are generally simpler, more focused, and do not
hold the subject's "primary provision" of hacking the methods of platform
module.




## intro

"boxxy" is an enhancement option available under the [#024] "autoloader"
enhancement stack. its name originated from the idea that it makes any
arbitrary platform module act something like a [#061] "box" (that is,
something like an ordered hash), however, what it actually does to the
subject module is really its own thing that has become a local idiom,
as described below.

(the actual name itself with the weird spelling is out of deference to
the figure of the 4-chan pantheon, whose reign was contemporary to the
subject library's inception.)




## objective & scope

at its essence, the subject enhancement rewrites the module's `constants`
method so that it peeks into the filesystem to *infer* constants that
may not be loaded yet. two important questions arise immediately from this:
(1) why on earth would you want to do this?, and (2) at what cost?



### 1. why on earth would you want to do this?

probably the only reason you want to do this, really, is if you want to
"reflect" on all the items in a filesystem collection (very often these
are something like plugins in a plugin directory; but they could be
anything) without having to load the main file (i.e corefile or eponymous
file) for each item. so, it's an optimization to save on the overhead of
the filesystem hit and loading of asset file(s) for each item.



### 2. but at what cost?

the main issue is with "isomorphic dissonance" between filesystem names
and const names. generally we can infer the filesystem node name from
a const name, but we cannot go the other way with certainty. for one
example, the file `foo-bar.kode` might contain any of `FooBar`, `Foo_Bar`,
`FOO_BAR`, or others. all of those constants *must* (generally) live in
the file `foo-bar.kode`; however you don't know what constants that file
defines just by looking at the filename.

our "solution" for this in the case of boxxy is this: the result you get
from calling `constants` on a boxxy module *might* contain "inferences".
you have no way of knowing if it does and if so, what those inferences are.
all you know is that if your asset tree follows the "rules" of [#024] #note-2,
calling `const_get` on that module with any of the names in that array
will produce a value.




## avoiding the gotchas :[#here.c]

if the name convention for all your relevant constants can be represented
in code and differs from whatever it is that we do by default, you can
define `boxxy_const_guess_via_slug` on your module (as a singleton method).

for example, one client when encountering a file "like-so" (or a directory
"like-so/") wants to constantize slugs `Like_so` rather than `LikeSo`.

if you have one or a few pesky names that (for example) have a run of all-
caps, it's possible that you could work around boxxy's (intrinsic,
unavoidable) inefficacy here by specifying the challening names as [#031]
stowaways, in concert with the use of boxxy. (stowaways plus boxxy happen
in [cu] but are not yet well tested here.)




## implementation provisions, axioms, assumptions, etc :[#here.D]

### implementation overview

what we do generally is take a snapshot of the relevant file tree at some
moment and use this to "supplant" some of those methods of `::Module` that
pertain to constants (namely `constants` and `const_defined?`) by making
*inferences*. as mentioned above, our implementation is concerned in part
with "paying back" these inferences.

(EDIT: above - no more etc.)

these inferences are *not* based on an assumption of a two-way isomorphism
between "constantspace" and filesystem: we allow that there can be arbitrary
constants defined in the subject module that have no counterpart node in the
filesystem. however, for the converse we *do* model as a strong
isomorphism: any "nodes" that we discover through the mechanism of
[#024] #note-1, we model an inference of the existence of an "approximated"
const when a corresponding "concrete" const is not known.

so the founding axioms are that we can (in one direction) go from a "const"
to a (filename) "head" and (in the other direction) *infer* an approximated
const *from* a filesystem head. while this former operation is deterministic
by our own rule; the latter is not and so must handle its own inference
errors. this should make no sense at this point.



#### how do we conceive of the filesystem?

at the time the (at writing) controller is made, an ad-hoc index structure
is made from the state of the filesystem at that moment.

(as such, changes to the filesystem after this moment won't be picked up,
which in real life is never a problem for us because nothing is this long-
running for us in practice.)



#### how do we conceive of the constantspace?  :[#here.D.3]

whereas the relevant state of the filesystem is seen as static, the state
of the "constant space" is seen as arbitrarily dynamic. that is, we never
cache anything that assumes a static constant space (unless noted
explicitly). more specifically,
we design our implementation with these two (accurate) assumptions about
constants:

  1. any const that is not yet set (i.e "defined") may be set at runtime.
     (in fact, all consts that we will ever define are set at runtime
     because there is no compile- time in this platform, to any extent
     that concerns us.)

  2. once a const has been set (i.e "defined"), it cannot be unset.


#### how do we use this ad-hoc index?  :[#here.D.4]

as relevant to the platform operation being performed (e.g `constants`
or `const_get`), we will (usually) use this ad-hoc index to "supplant"
those operations with inferences based on the information we gathered
from the filesystem.

but in a hypothetical scenario where progressively more and more of these
asset files are loaded over time (during any particular runtime), these
loadings fill in the holes in our knowlege so that assets whose names we
once inferred now become concrete knowledge.

in a hypothetical eventual case where all the asset items are loaded,
there is no need to "augment" these operations with inferential
approximations, because all the concrete names are known.

by this rationale we conceive of this ad-hoc structure as a [#ba-061]
"diminishing pool" that will either reduce in size or stay the same size
over time. if it ever gets down to a size of zero we can deactivate this
entire hack from the subject module (to the extent that we can).




## mini case-study: why we cache names and which names we cache :[#here.5]

one novel use case for boxxy is its application in [cu] where the
consts (both inferred and real) of a particular module are used in
a direct way to unserialize a serialized data structure. if you
like, the "entity" is like an [acs] component, with many sub-
components each of which has a counterpart node in the const space.

"names" in the (human readable) serialized input (imagine lowercase
with underscores) imply directly a corresponding const that is then
dereferenced against the boxxy module, whose referent (in turn) is
used to parse the rest of the input after than name until the end of
the line of input (or something like that).

for such a case we do a lot of the same translations of names from
one format to another over and over again for the same small-ish
set of names. we cache these name functions so that we avoid the
overhead (both memory and processing) of translating these same
names repeatedly.

but we do not cache every name structure that we build because
(depending on how it's used) it could eat up a lot of memory
unnecessarily. (imagine if the "operator branch" was use to parse
arbitrary input streams.) so we only cache those names that are
determined to be members of the boxxy module.




## exposure justification :[#here.F]

after boxxy's very first "phase", when it cycled into a phase of what we
would consider mature, its primary principle was that of the "unobtrusive"
overriding of platform methods (2 in particular). (not monkeypatching,
mind you, but just overriding 2 methods on participating modules.)

in practice, one of these provisions has served us well; and the other one
was problematic (HISTORY)

in practice this approach worked well for enhancing the `constants` method
of the participating module, but overriding `const_defined?` created far
more problems than it solved. our solution to *that*, in turn, was to
elminate this overriding of the `const_defined?` method. to accomodate this,
affected clients had to refactor workaround.

, so boxxy before this version saw that method
removed and all affected clients refactored workarounds.

we have returned anew to the desire to have a method like this,
but ou

our answer to this now

so what seems more apt is to utilize "composition" (smaller, dedicated
classes) rather than overriding essential platform methods to have
"magic" behavior, an anti-pattern that for better or worse boxxy was
founded on. per [#030.D.3], do not assume a static constantspace.




## code notes :[#here.G]

### :#note-1

this is not an idempotent operation - if we were to use an `alias_method`
to grab the original (pre-boxxy) method implementation, it would expose us
to the risk of nasty bugs (infinite loop probably) if we were to enhance
the same module instance as "boxxy" more than once.

no other operation in the enhancement algorithm as far as we know is
vulnerable to this. that is, probably they are all idempotent.



### :[#here.G.2]

boxxy modules generally don't have a corefile (i.e they are usually a
"cordoned-off box module") but if they do (covered) we do *not* want an
inferred const `Core` showing up in the augmented list of probable consts.

since this is rare in real life, we do not bother "optimizing" the loop
to stop checking for this case after it is encountered.

if you did have a meaningful item node called `core` with representation
on the filesystem, we have not encountered this requirement and so we have
not covered it, but probably a stowaway entry would be a start. perhaps one
that loads the file (yikes) "manually"..



### :[#here.G.3]

we assume the user-generated const won't collide with any (user-specified)
stowaway entries, but that is of course not guaranteed. a sanity check is
raised on const name collision (not covered). if this does occur, we can't
think of a good reason why you have a stowaway entry when there's an
isomorphic filesystem node there.
