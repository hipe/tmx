# the option scan narrative :[#095]


(ancient comments, originally in code).


## introduction

an adaptive layer around an optionparser for iterating over its options.
Iterate over a collection of option-ishes, be they from a stdlib o.p
or somewhere else; given either another iterator of arbitrary objects
that might be switches, or an o.p-ish.



## behavior

yields each of the strange switches of the option-parser-ish it gets. The
sole argument to the constructor must either `respond_to` `each` and yield
successive switch-ish'es or quack like an ::OptionParser in that it respond
to `visit` and work like stdlib o.p does w/ regards to a stack that responds
to `each_option`.



## justification

This is useful because it's far too hacky to do the below thing to a stdlib
o.p in more than one place, in the universe.  our out-of-the-box criteria for
what we mean by "switch" is: it is a nerk that responds to *both* `short` and
`long`, and one or more of them is a true-ish of nonzero length.

note that this check is necessary because there exist in our universe
switches that do not meet this criteria. they may be produced by hacks
or whatver. [#sg-030] may be an example.
