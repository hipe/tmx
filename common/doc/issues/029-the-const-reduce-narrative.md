# the const reduce narrative :[#029]


## 4 categories of const name

for our purposes any "const name" (in reference to any particular
"current module") can be determined to be in one of four categories
(and assume that a name is a symbol or string);

1) the unsanitized const name is invalid. (`fooBar` is an invalid
   const name. `FooBar` is valid.) (we'll be using Name#as_const
   which will convert the former to `Foo_Bar` probably. but a name
   like `123foo` cannot be converted losslessly to a const name.)
   name resolution cannot procede with an invalid name.
   (the remaining categories are for valid const names.)

2) the valid const name corresponds to a value, i.e it is
   "initialized". (these are the consts we typically deal with in
   real life almost all of the time.) such a case means we are
   finished for this step, having resolved a value for the name.
   (the remaining categories are for uninitialized consts.)

3) the valid but uninitialized const is an incorrect "variant" of
   a correct (i.e initialized) const name. e.g, when you say
   `Foo_Bar` to mean `FooBar` or `FOO_BAR`, or the opposite, etc.
   how we resolve (or don't resolve) a value for such a name will
   be discussed in code and tests.

4) a value cannot be determined for the const, even after trying
   the variants above. a value cannot be resolved for the name in
   such a case.

(two refactor-rewrites ago this was "three laws compliant".)




## :"general algorithm"

here's the overall general algorithm: with the given module as the
"current" module, for each term in the array of const names,
attempt to resolve a value from the current module using this term.
if we hit case (1) or (4) from above, this is a dead end and we
stop. but for (2) or (successful) (3), let this resolved value be
the current value. if you just did the last of the const names, the
current value is the result. otherwise, assume the current value is
a module. make it the current module and repeat until done.




## options

### :#correct-the-name

in summary, this option is to un-do boxxy's name-munging.

this is a retro-fitting feature only for legacy users of [#030]
"boxxy". boxxy peeks the filesystem to make inferences about what
consts are defined, but this is necessarily a lossy guess so names
can be munged. (e.g, if it sees that a file "foo-bar.rb" exists,
it will say  that `Foo_Bar` is `const_defined?`, when actually the
file might define `Foo_bar` or `FOO_BAR` instead.)

this option is for the client to indicate that such a scenario might
happen. with this option on we do extra work to correct the name of the
resultant pair. (oh and this option only makes sense to use in concert
with `result_in_name_and_value`, which we won't check for or imply.)




## :#death-to-the-peek-hack (#tombstone)
