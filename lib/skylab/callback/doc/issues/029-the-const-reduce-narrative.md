# the const reduce narrative :[#029]


## :#assume-is-defined

we set 'assume_is_defined' as a hack to bridge a gap btwn old and new, and
also because we haven't yet come up with a good interface to facilitate the
fuzzy loading of consts inferred from paths.




## :#death-to-the-peek-hack

the 'peek hack' was a true true hack that old boxxy used to offer in one of
its dark, undocumented corners. the new autoloader "solves" this same problem
generally, but in a way that is much more rigid and much less disgusting.

in fact the re-architecting of the re-written autoloader probably owes
its initial inspiration to a quest for a better solution to this problem.

specifically the "peek hack" was/is something like this: for certain topolgies
(what we used to call "tall, narrow trees") when you don't know the
casing/scheme for a const name (of a particular class of branch node), you
(*gulp*) use a string scanner to parse the bytes of the file **before ruby
even gets to it** in order to "peek" at what the casing/scheme is of the const
in question, so that you can vivify the module with the correct casing before
you even load the file that refers to the module (but in fact effectively
creates it). that we ever did this makes us shudder to even type it.

however while old a.l exists, this is [#027] a thing we do to to comport to
old a.l, just in case there is some reason that we want this information, that
a peek hack was requested. but we look forward to the day we can erase this
entire documentation section and every mention or use of a peek hack in the
code.
