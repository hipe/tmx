# introducing CLI client DSL :[#088]

(these are somewhat archival - they were a bit to verbose to be inline
with the code)

## when to use the (simple) CLI client DSL?

You leverage the dynamics for synergy presented herein when you want
a) the conveninece of a DSL but b) your CLI is simple and doesn't have
subcommands (i.e isn't a "box"). Everything is experimental and subject
to change and will definately break your app. Everything.

`default_action` - your default action is simply an instance method
your client defiines that iself results in the name of another method
to be used as the default "action method" - this in turn is the
method name to be used as an "action method" if for e.g the queue
is empty after parsing any opts, and the engine needs to decide what
method to use to process the request.

This action method will in turn be used possibly to parse argv args
with, and then this method will be called with any valid-arity-having
argv.

A common default name for this assumed elsewhere is `process`, however
it is the opinion of the present author that you should use a name
that is expressive (in one or two words) about what your particular
action actually does. Hence this method (er., dsl writer) can be used
to indicate that.


`build_option_parser` -- different than the other two (e.g) same-named
instance methods defined in another DSL module elsewhere, this is a
straightforward default implementation of b.o.p that creates a stdlib
o.p and runs any definition blocks on it that you may have specified
and adds a (hopefully) correctly wired help option iff you didn't
specify what looks like one ("-h") yourself in one of your o.p
definition blocks.

If your option parser has a special plan for the '-h' switch, the below
default help wiring won't trigger, so you might want to wire help
differently (e.g just '--help') and follow the below as a model (that
is, do "enqueue :help" in the handler for your option).


## "on wiring the module graph for autloading"

this deserves some explanation: we use Boxxy on our action box module
because that was exactly what it was designed for: to be an unobtrusive
hack for painless retrieval and collection management for constituent
modules. now the point of this whole nerk here is to _create_ such a
box module and, *as the file is being loaded*, blit it with classes
that are generated dynamically to model all of your actions from
methods as they are defined. that's the essence of why we are here.

While some actions (e.g. clients) may not need an autoloader, if
there's any chance they do it must be wired properly, and that is
convenient do below when the modules are created rather than at some
later point (e.g after the file is done loading, as recursive a.l does)

BUT it is also nice to be able to extend a *base (action) class* with
this DSL extension and have it work in *child* classes. While we could
do some awful hacking to make the autoload hack work for subclasses
as they appear in other files .. just no.

All of this is to say: 1) that is why we include a.l above, and
2) this is why we have some conditional nerking around below, to charge
the module graph with autoloading only if it has signed on for it.

(btw you would do that via either extending a.l explicitly on your class
*before* you extend this .. *and* i think the client DSL will do it
for you too if that fits your app.)

_
