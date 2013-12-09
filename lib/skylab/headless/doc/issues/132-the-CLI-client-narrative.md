# the CLI client narrative :[#132]


:#storypoint-1

what is really nice is if you observe [#sl-114] and specify what actual
streams you want to use for these formal streams. however we grant ourself
this one indulgence of specifying these most conventional of defaults here,
provided that this is the only place library-wide (universe-wide, even) that
we will see a mention of these globals.



# the CLI client DSL narrative :[#129]

(#parent-node: [#126] headless CLI component narratives)

:#storypoint-950 introduction

you leverage the dynamics for synergy presented herein when you want a) the
conveninece of a DSL but b) your CLI is simple and doesn't have subcommands
(i.e isn't a "box"). everything is experimental and subject to change and will
definitely break your app. everything.



:#storypoint-960 the order here matters

extension modules (ie "MMs" and "IMs") must be included in order from general
to specific such that the more specific ones end up as nearer to the "front"
of the ancestor chain, such that they in turn intercept any method calls
(#hook-ins for sure) that they intend to intercept before they reach the more
general, "outstream" modules.

(:+#neologism: :#outstream in the same sense as up "upstream" or "downsteam"
but refers specifically to a more general (posibly surrounding, hence "out")
node. conversely, "instream" means more specialized or specific: an "instream"
call would be one (perhaps a #hook-out or #hook-in) that gives the client a
chance to perform the operation in a customized way (because for example
a "#hook-in" method was overridden). factory pattern could be described as an
"instreaming" operation: the agent that the factory produced for performing
some operation is the "instream".)

as a "top-client" (however intermediate we may actually be), we are typically
defined in a file whose location is isomorphic with our node name (that is, a
top-client is rarely a #stowaway). child action nodes, however, are typically
defined wherever and all over the place (e.g they may be produced dynamically).

all of this is to say that where and how we are created has an impact on how
autoloading should be wired (or it may not), but to be safe we take care of
that up front before we call out to our outstreams; so then presumably the
outstream won't overwrite our explicitly wired autoloader properties with
something wrong. (in other words and in more specific terms, all of this is
so that MAARS::Upwards isn't actuated on a top-level node (which a top-client
may be but not a child action), which reasonably results in an exception.)

not all top-clients are boxes and not all boxes are top-clients, but we
conceive of a top-client as "more specifc" than a box because of its
#topper-stopper role: it must intercept methods that might otherwise be
delegated upwards to a parent client. hence we enhance ourself as a box
before we enhance ourself as a client.

very lastly we employ our own MMs and MMs -- which may be implemented as
#bundle-as-method-definition-macros -- because that is the most specific
thing of all in all of this (besides whatever the human client writes
in the client class). because we know that the outstream has added a
'method_added' listener, we turn the DSL off when our method macro adds
methods (which in theory shouldn't be necessary but feels nicer).

this is a concern that is relevant to everywhere that we employ bundles
after employing a DSL that uses a 'method_added' hook.



:#storypoint-970

we may implement bundles as procs below. all of the ramifications of
[#121] the design pattern of "bundle as method definitions macro" must be
considered.



:#storypoint-980 (method)

your default action is simply an instance method your client defiines that
ltself results in the name of another method to be used as the default action
method - this in turn is the method name to be used as an action method if for
e.g the queue is empty after parsing any opts, and the engine needs to decide
what method to use to process the request.

this action method will in turn be used possibly to parse argv args with, and
then this method will be called with any valid-arity-having argv.

a common default name for this assumed elsewhere is `process`, however it is
the opinion of the present author that you should use a name that is
expressive (in one or two words) about what your particular action actually
does. hence this method (er., DSL writer) can be used to indicate that.



:#storypoint-990 (method)

different than the other two (e.g) same-named instance methods that may be
defined in another DSL module elsewhere, this is a straightforward default
implementation of b.o.p that creates a stdlib o.p and runs any definition
blocks on it that you may have specified and adds a (hopefully) correctly
wired help option iff you didn't specify what looks like one ("-h") yourself
in one of your o.p definition blocks.

if your option parser has a special plan for the '-h' switch, the below
default help wiring won't trigger, so you might want to wire help differently
(e.g just '--help') and follow the below as a model (that is, do
"enqueue :help" in the handler for your option).
