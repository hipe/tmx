# thorny corner :[#043]

## the problem

a tug made unto an auto-vivifying node will of course auto-vivify the node
being requested in cases where the branch node exists (folder). the problem
is that because under the combination of ruby syntax and our conventions
for file naming,
(and related but not the same as [#hl-083] "constants can hold more
information"), there is not a perfect isomorphicism between constant names
and filesystem names -

  constant  | file
       Foo  | foo.rb
       FOO  | foo.rb
   Foo_Bar  | foo-bar.rb
    FooBar  | foo-bar.rb

that is, there is one-way lossiness going on. we can always cleanly infer
the "correct" name for a file given a constant, but the reverse is not
true. for any file whose stem name is more than one letter long there exist
multiple constants that may validly reside in it (co-occurring, even).

a solution whereby we restrict our constant names to that subset that would
work cleanly around this problem is no solution at all, because we follow
important conventions within the variety of name-forms for constants (indeed,
three are exhibited above, and those aren't all of them).

furthermore, and a bit out of scope, we don't like the idea of being
strict on our insistence of using dashes and not underscores (or, gasp,
nothing) in filenames; if only for the reason of this library having more
broad applicability.

..

we were hit by this example:

  "headless/nlp/en/levenshtein-.rb"

the simple challenge here is to take that "locally normalized" (anchored)
filesystem path and convert it (by loading it if necessary).

what may come as sad news to some, but is just fine by me: we should not
just load the file. the entire system is built around the notion that
subnodes need never worry about loading their supernodes, and, in that
pathname, that leaf node would have three parent nodes not necessarily
loaded if we just loaded (or require) that path. the benefits that this
architectural convention brings us far outweigh the cost touched on here.

specifically in the case of the above, *both* the tokens "nlp" and "en"
are cased as "NLP" and "EN" when they are constants. *and* there exists
no leaf node for "nlp" - that is, there is no "nlp.rb" file.

.. this is boring i'll come back later
