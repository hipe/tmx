# notes about the "stowaway" subsystem :[#031]

## how string-based stowaway specifiers are interpreted

for aesthetics and agility, stowaways expressed in this string form
are interpreted as "node path tails" rather than just as filesystem
path tails. this means the loading is supposed to "just work"
whether the the asset is in an eponymous file or a corefile, using
the same specifier string either way. (these strings are assumed
never to have a filename extension.)

all we are doing is loading a single file - we do no special work
for intermediate nodes in a deep tail. we'll use the file tree cache
only to peek at the shape of the file we are about to load, in order
to resolve a full filesystem path (with extension included) from
the node path tail.




## a primer on stowaway "theory" by way of looking at "deep tails"

### (also, "practical distribution" of tall, narrow asset trees)

we do no loading of intermediate nodes in cases of a "deep tail" -
there should never been a need to do so, because if there were any
intermediate files to load, for each such would-be file it is the
"natural" asset node defined in that file that should be the host
for the stowaway (recursively). this should make no sense at this
point.

imagine we have an asset that in implementation is all "big toe".
normally, the big toe is part of the foot and the foot is part
of the leg and so on. a filesystem tree for such a hierarchical
structure with "normal asset distribution" might look like this:

   [..]

    leg
     ├── core.kd        # implementation of "leg" here
     └── foot
          ├── core.kd   # implementation of "foot" here
          └── toe.kd

so there are three files and two directories there. but as we said
above, in this case we are all "toe". because we have no real assets
to provide for "leg/core.kd" and "leg/foot/core.kd", the loading of
those files is seen as being "wasted" on this formality. (of course
nowawadays we might reconsider our structure not to be so deep and
narrow, but regardless we want our autoloading to accomodate this
general design factor - that of allowing for a "practical distribution"
for deep narrow trees, one that can still [semi-] autoload everything
without us needing ot have "anemic" (i.e "orphan") files.)

for this imaginary model, here's our ideal "practical distribution":

    leg
     └── foot
          └── toe.kd   # needs to define "leg", "foot" as well as "toe"

note that we have eliminated the "anemic" files, and so in the above
file tree there's only one file (and still two directories).

the idea here then is that the file called "toe.kd" would take on the
responsibility of defining "Leg", "Leg::Foot" *and* "Leg::Foot::Toe"
all.

(the fact that we don't just put all the assets in a file called
"leg.kd" is an aesthetic choice, with the rationale that it's misleading
to have a file called "leg.kd" that mainly defines the "toe" asset.
this is an aesthetic design factor the cost of which we pay back here.)

so the trick there is that when "Whatever::Leg" triggers a const missing,
somehow the autoloader will know that "leg/foot/toe.kd" is what needs to
be loaded.




## the autoloaderization "contract" for stowing away

the "only" problem with stowaways is that it breaks the "normal" flow
through which the particular host file would be loaded. normally when
a const is missing under some given "autoloaderized" module, we resolve
which file path (corefile or eponymous file) to load, we load the file,
and then we (maybe) further autoloaderize the loaded asset, before
producing that asset as the final result.

the essence of stowing away is that we specify explicitly that the
stowed-away asset is defined in some filesystem node other than that
which we would derive normally. the corollaries of this are the focus
of the remainder of this section, as well as being the primary concern
of the stowaway subsystem's implementation generally.

first let's consider different case-categories we can have for stowaways,
in terms of the number of host assets that are also involved.

  - "1 and 0": historical note - imagine a scenario where the host file
    holds the definition of *only* the stowed away asset; and there's no
    other "host" asset to speak of.

    while we may no longer encounter this category of cases now; this is an
    arrangement we used to employ for allowing that a node called
    `Foo::TestSupport` is in a file called 'foo/test/test-support.rb' or
    something similar. we *think* we no longer employ this pattern because
    we have since employed "correct" gemification of sidesystems, and to
    do so takes the test tree so far outside the asset tree that we just
    load these assets "manually" now (with a hand-written method rather
    than autoloading).

  - "1 and 1": if there's one host asset and one stowaway asset, after we
    load this file under the stowaway subsystem we may have to
    "autoloaderize" the host asset. (if this file was loaded normally, the
    host asset will be maybe autoloaderized normally, and the stowed-away
    asset will get no treatement at all.)

  - "N and 1": imagine that a given host file hosts multiple stowed-away
    assets..




## document meta
  - full rewrite #tombstone
