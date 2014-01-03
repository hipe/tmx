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
