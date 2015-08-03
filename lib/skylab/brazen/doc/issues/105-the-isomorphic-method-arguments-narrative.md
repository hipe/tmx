# the isomorphic method arguments narrative :[#105]

## intro

see [#103] for important caveats and historical context.




## (salvaged from old [#!hl-065])

basically all we are ever doing with arg parsing at this level is verifying
that the number of arguments passed one of the set of valid numbers of
arguments supported by that particular argument syntax. (this concept is
referred to generally as 'arity' and is something we go crazy with over
in [fa] but not here, in as precise of terms).

this is something that programmers are used to dealing with all the time,
becuase it is exactly isomorphic with passing arguments to methods. (at least,
this is true for the kind of argument syntaxes implemented by this node).
this isomorphicism is one of the obsessions of this library..



## explaining this formal arg structure; introducing reqity :[#.A]

this is a vestige of what used to be an important top node in [hl]
("argument", that is, formal argument of argv and a counterpart to
"option" as a formal option of an o.p). currently we make it quack like
a modern property of [br], but we do not subclass the same. however this
is an avenue worth keeping in mind IFF there is too much redundancy of
method implementations here. ( but note that when we call these "hook
outs" it makes them OK. :P )

what follows is from the original work:

this node is little more than a struct that wraps together one formal
parameter and one symbolic "reqity" value.

"reqity" is a term we straight up invented to refer to that property that is
either :req, :opt or :rest, as seen in the result structure of ruby's
::Method#parameters. (#todo see what it is called in the source).

a lot of this node is concerned with making the argument object jive with
the #parameter-reflection-API.

the children nodes of this node (in this same file) is where it gets more
interesting: the 'Syntax' child has an 'Isomorphic' subclass that implements
the "argument syntax isomorphicism".

this node's original (original) inspiration was is getting ruby to generate
::ArgumentError exceptions that would contain useful messages in them
"(wrong number of arguments (2 for 3)" but this isomorphicism soon leaked
(it was mechanically stupid to do it this way, however fun). what it turned
into is much, much more stupid and much more fun..





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
