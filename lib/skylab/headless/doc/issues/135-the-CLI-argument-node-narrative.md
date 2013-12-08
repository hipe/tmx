# the CLI argument node narrative :[#135]

:#storypoint-1

this node is little more than a struct that wraps together one formal
parametr and one "reqity" value.

"reqity" is a term we straight up invented to refer to that property that is
either :req, :opt or :rest, as seen in the result structure of ruby's
::Method#parameters. (#todo see what it is called in the source).

a lot of this node is concerned with making the argument object jive with
the #parameter-reflection-API.

the children nodes of this node (in this same file) is where it gets more
interesting..


:#storypoint-2

":block" is a value that this term may assume from the ruby reflection API,
however it is a case that we do not represent here. we want KeyError to
be triggered if ever we are reflecting on a method signature that takes
a (necessarily named) block parameter because currently that class of
parameter has no isomorph (nor should we try to make it have one!) with
CLI command signatures.


:#storypoint-3

for error reporting it is useful to speak in terms of sub-slices of argument
syntaxes (used at least 2x here). (in fact, this class was originally
sub-class of ::Array (eek!)). so we still see necessary remanants of that
shape paradigm here.


:#storypoint-4

there was once a `string` method defined here, but it was an interesting
smell, for the act of rendering a syntax into a string takes into account
so much design behavior that it would be a crime to do it automatically
here. the argument sytax is the model, not the view.
