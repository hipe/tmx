# boxxy

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




## overview

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




## implementation notes

### implementation overview

what we do generally is take a snapshot of the relevant file tree at some
moment and use this to "supplant" some of those methods of `::Module` that
pertain to constants (namely `constants` and `const_defined?`) by making
*inferences*. as mentioned above, our implementation is concerned in part
with "paying back" these inferences.

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



#### how do we conceive of the constantspace?

whereas the relevant state of the filesystem is seen as static, the state
of the "constant space" is seen as arbitrarily dynamic. that is, we never
cache anything that assumes a static constant space. more specifically,
we design our implementation with these two (accurate) assumptions about
constants:

  1. any const that is not yet set (i.e "defined") may be set at runtime.
     (in fact, all consts that we will ever define are set at runtime
     because there is no compile- time in this platform, to any extent
     that concerns us.)

  2. once a const has been set (i.e "defined"), it cannot be unset.


#### how do we use this ad-hoc index?

as relevant to the platform operation being performed (e.g `constants`
or `const_get`), we will (usually) use this ad-hoc index to "supplant"
those operations with inferences based on the information we gathered
from the filesystem.

but in a hypothetical scenario where progressively more and more of these
asset files are loaded over time (during any particular runtime), these
loadings fill in the holes in our knowlege so that assets whose names we
once inferred now become concrete knowledge.

in a hypothetical eventual case where all the asset items are loaded,
there is no need to "supplant" these operations with inferential
approximations, because all the concrete names are known.

by this rationale we conceive of this ad-hoc structure as a [#ba-061]
"diminishing pool" that will either reduce in size or stay the same size
over time. if it ever gets down to a size of zero we can deactivate this
entire hack from the subject modue.




### :#note-1

this is not an idempotent operation - if we were to use an `alias_method`
to grab the original (pre-boxxy) method implementation, it would expose us
to the risk of nasty bugs (infinite loop probably) if we were to enhance
the same module instance as "boxxy" more than once.

no other operation in the enhancement algorithm as far as we know is
vulnerable to this. that is, probably they are all idempotent.
