# the stowaway narrative :[#031]

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

we do no loading of intermediate modules in cases of a "deep tail".




## :#note-1

the "only" problem with stowaways is that it breaks the "normal" flow
through which the particular asset file would be loaded. that is, we
only need to engage the stowaway mechanics if the particular asset file
hasn't already been loaded "normally" (which normally happens IFF its
main (isomorphic) const it defines has already been autoloaded). note
that if this file had already been loaded normally, then we wouldn't
(shouldn't) ever be triggering const missing on the stowaway asset in
the first place, because its file would already have been loaded, and
that file should have defined the stowaway const.

the only problem with *this*, then, is this: normally, after we have
loaded an asset file, we "autoloaderize" the loaded asset as appropriate.
when we load the file for the stowaway instead, we aren't in a convenient
position to autoloaderize the "main" asset that file defines because we
don't just magically have any sort of handle on it out of the box.

assume it is always the case that for node that *hosts* stowaways
(whether an eponymous file or a corefile), it is always conventional
in the sense that "basename" of its node path has an approximation
that matches the "basename" of its const name.

it used to be that we had "narrow stem" stowaways; now we don't; so
we're going to hack through this problem the easy way for now.




## document meta
  - full rewrite #tombstone
