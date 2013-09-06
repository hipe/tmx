# assorted CLI things explained


## option parser

out of the box we don't decide how to build your option_parser. you must
define `build_option_parser` yourself. even if you have a grammar that
takes no options, just result in falseish, but you must still define a
`b.o.p`, to keep things explicit. (the DSL however is different.)
whatever if anything you result in from your `b.o.p`, if you result in a
true-ish it must follow a core interface for an o.p, one that is a tiny
subset of (and of course based off of) the public methods of stdlib's o.p:

  + your o.p must provide a `parse!` that takes 1 array arg, like o.p
  + on parse failures your o.p must raise a stdlib o.p::ParseError
  + your o.p must have a `visit` that works like stdlib o.p
  + each switch must have a `long`, `short` and `arg` that look like o.p

