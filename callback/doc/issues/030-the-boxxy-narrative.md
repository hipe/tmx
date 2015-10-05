# :#the-boxxy-narrative

## introduction

this incarnation of boxxy is a rewrite of the legacy boxxy which has been
removed from the current universe but exists in history as "[m-h]/boxxy.rb"

boxxy is an enhancer for modules. it is essentially a collection of methods
that affect these modules with a set of behaviors each of which falls into
one of two categories:

1) convenience methods that allow the module to be treated more like a
   collection ("names" returns an iterator of name objects,
  `each_const_value` is comparable to `each_value` of a hash)

2) overrides for `constants` and `const_defined?` that implement
   [mh-029] "isomrphic-filenames".


## :#the-boxxy-methods (a.k.a :#boxxy-like behavior)

these are optional and always experimental: they hack 'constants' and
`const_defined?` to do fuzzy inference based on the files in the filesystem
(without loading them!). this is convenient when it works but can potentially
be a headache when it doesn't..

the boxxy methods module has a particular set of skills that it uses to make
each next module it loads also be a boxxy module. for this to work the
ancestor chain must be right in that boxxy must sit in front of the universal
base methods.

this pattern in general is why we must ensure that the universal base methods
must get put on the chain "first" so they are not in front when others are
added that wish to overrride them.

the boxxy methods hack `constants` and `const_defined?`, and do not concern
themselves with `const_missing` or `const_get`.


### :#the-fuzzily-unique-entry-scanner

the idea here is that it is useful to be able to enumerate over the set
of unique "distilled stems" in a directory: in such an enumeration, a file
"foo.rb" and a sub-directory "foo/" will only get one representation.

such an enumeration will be useful to come up with a list of fuzzy const
guesses that represent constants that may not be defined yet but probably
can be defined.

experimentally we are using the "entry" class to be the object that is
yieded by this enumeration or scanner. benefits and disadvantages to this
choice are explained below.

furthermore, in this corner we will recognize fuzzy siblings of the same
entry type (file or directory) as problematic and a runtime exception
will be raised (e.g a file "foo-bar.rb" and a file "FOOBAR.rb").

however it is normal to have a file and a folder that have the same distilled
stem ("foo/" and "foo.rb"). so we may have at most one in each category that
shares a distilled stem.


### :#fuzzy-sibling-pairs

because we are overloading this concept of "entry" to hold behavior for a lot
of different concerns, we need to be sure we have deterministic and rigid
behavior for this "fuzzily unique entry scanner". in the case where we have
both a file and a folder with the same distilled stem, we have to pick one
or the other to represent the distilled stem, and be consistent about it.

depending on whether we need it, we associate the other to the one so that
both may be reached when enumerating the directory in this manner.

in such cases where we have both file and directory with the same stem,
we chose the file to represent the pair, and we may dangle the directory
on to the file if it's useful. we chose the file because this reflects the
order of precedence used by the autoloader itself.
