# the specer narrative :[#025]


## :#storypoint-5 introduction

the specer accepts a sequence of Comment_::Block-s one by one and for each
one it parses it line-by-line, chunking it into runs of 'code' and 'other'.
it always holds on to the last 0 to 2 contiguous lines of 'other' so that
they can be associated with 'code' runs, for possible use in their example
and description strings.

when it encounters a blank comment line, it associates it with the preceding
run of 'code' or 'other' as appropriate.

for now, this is where the logic is seated the you need 4 (four) blank lines
(more is ok) to look like a 'code' line; and for now this is hard-coded but
etc.

a second pass of parsing happens in the child nodes from this file.



## :#storypoint-15

we don't process template options, the "templo" does; hence we always result
in success at this point.



## :#storypoint-165

the `const_a` looks something like [ :Foo, "Bar", :Baz ] (it is indiscriminate
of strings vs. symbols), to stand for the value represented by the constant
::Foo::Bar::Baz (or perhaps Foo::BAR::BaZ, etc). at this point, that value
hasn't necessarity been 'loaded' yet..



## :#unfortunate-hack

the way the universe is laid out at this moment, the topmost node does not
provide any autoloading, but generally all of the rest of the nodes that
"need" it do. sadly this architecture facet is effectively hard-coded into
this spot here, for lack of design. one day we may just go ahead and give
the top node autoloading, but we have been avoiding that for want to keep
it "pure".

alternately one day we might bake all the power that is within "autoloader 2"
into something external instead, but currently its implementation requires
that nodes extend its extension module(s), so for nodes that do not do this
but where we need particular loading behavior, a subset of it has been put
into this const reduce function. ("assume is defined" is a flag that when
true effectively states that we rely on the node to resolve "const missing"
events itself so we trigger them on purpose.)

hence we need to rely on the "const reduce" function to load any necessary
files itself for missing consts, but only when the node doesn't manage
autoloading itself, i.e. the top node. this "is not top" test is for that.
