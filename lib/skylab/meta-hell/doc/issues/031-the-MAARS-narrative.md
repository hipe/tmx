# the MAARS narrative :[#031]

## :#introduction

"MAARS" stands for "MetaHell Autoloader: Autovivifying Recursive" (the 'S'
is added for aesthetics: with the 'S' added it both sounds like the planet
name and the excellent music project project from the late 80's ("M.A.A.R.S")
of "pump up the volume" fame).

we periodically try to shorten the name to something as concise but more
mnemonic, but no other name ever sufficiently encompasses exactly this
particular behavior payload, so the name has stuck and will probably continue
to stick for a while.

this adds "recursive" to the autovivifying autoloading behavior described
in [#029] its narrative, which is recommended reading to accompany this
narrative.

"recursive autoloading" refers generally to the process of autoloading a node
(usually a class or non-class module, but not necessarily); and then if that
node is a module, mutating that module to itself be a recursive autoloader.
this loaded module will then perform the same mutation on any nodes *it*
loads, and so on forever downward.

for a quick note on taxonomy, "recursive" is not a specialized form of
"autovivifying". hypothetically one may want an autoloader that is recursive
but not autovivifying. but we haven't found a need for this yet, so we
build them in a chain like this.



## :#storypoint-90

turn a module and each of its not-yet enhanced parent modules into a MAARS
module. This works provided that it eventually hits a module that responds to
`dir_pathname` and responds with true-ish (and that everybody is using
isomorphic names).

note that we must *not* assume that "having"/"knowing" the `dir_pathname` is
isomorphic with `respond_to?` `dir_pathname` - in real life there are times
when the one is true but not the other so we must check for both. (for example,
in the case of a sub-class to a class who autoloads: when such a node is
loaded it may respond to 'dir_pathname' but the result may be nil, because
it hasn't yet been enhanced by this recursive enhancement process, and
expects to.)
