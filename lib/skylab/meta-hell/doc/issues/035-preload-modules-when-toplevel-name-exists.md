# issue 124 - Preload modules when toplevel name exists.


Issue [#sl-124] is that when we use names that are toplevel constants
our autoloading will fail, opting instead to use the toplevel constant
(while issuing a warning). Hence for such constants of ours we've got
to load those files "manually" (and non-lazily, that is, early).

At the time of this writing Issue::Models::Issue::Enumerator and
Issue::Models::Issue::File were examples of such.


## Thoughts on this

Such an autolaoding architecture presents a hypothetical problem with
forward-compatibilty becuse hypotheticaly *any* toplevel name could be
introduced into the core lib in the future, rendering all of our
autoloading (and all of our code) totally borked.

Both despite this and because of it, avoiding using the right name for
a thing because a toplevel name already exists is bad and wrong.

Probably in the future or in the present there will exist or does exist
a solution that will let us keep our code as clean as it is and still
reconcile the above issue.

~
