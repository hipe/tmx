# Preload modules when toplevel name exists. :[#035]

when we use names that are toplevel constants
our autoloading will fail, opting instead to use the toplevel constant
(while issuing a warning). Hence for such constants of ours we've got
to load those files "manually" (and non-lazily, that is, early).

at the time of this writing there were five occurrences of this issue,
all marked with the issue identifier (number).


## Thoughts on this

Such an autolaoding architecture presents a hypothetical problem with
forward-compatibilty becuse hypotheticaly *any* toplevel name could be
introduced into the core lib in the future, rendering all of our
autoloading (and all of our code) totally borked.

Both despite this and because of it, avoiding using the right name for
a thing because a toplevel name already exists is bad and wrong.

Probably in the future or in the present there will exist or does exist
a solution that will let us keep our code as clean as it is and still
reconcile the above issue, but for the time being it is the only big gaping
sore spot with an othewise perfect autoloding library.

~
