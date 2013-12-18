# the CLI client narrative :[#132]

## :#storypoint-5 introduction

welcome to the CLI client. if you are reading this you may also enjoy
an explanation of [#010] the client tree model.

the CLI client is a special kind of CLI action that manages the top-level
fulfillment of services that CLI actions need; but otherwise the bulk of
the implementation for such a CLI client lies in the CLI action node. hence
what we see here will be hopefully just a lightweight addition to that
(sizeable) node.



## :#storypoint-205

there is a sister section in our "outstream" (if a client is a specialize
form of action) that will introduce you to the issue and point you to
[#028] the stratified event production model, but the uptake of all of it is:
this spot will be the focus of some change.



## :#storypoint-255

what is really nice is if you observe [#sl-114] and specify what actual
streams you want to use for these formal streams. however we grant ourself
this one indulgence of specifying these most conventional of defaults here,
provided that this is the only place library-wide (universe-wide, even) that
we will see a mention of these globals.



## :#storypoint-305

this section is place for any necessary service methods that access
non-core facilities.



## :#storypoint-310

for now the way you access this facility is by calling this method from
inside the appropriate #hook-in method that resolves the instream status
tuple. see the instream node, which has its own narrative.



# the CLI client DSL narrative :[#129]

(#parent-node: [#126] headless CLI component narratives)

## :#storypoint-905 introduction

you leverage the dynamics for synergy presented herein when you want a) the
conveninece of a DSL but b) your CLI is simple and doesn't have subcommands
(i.e isn't a "box"). everything is experimental and subject to change and will
definitely break your app. everything.



## :#storypoint-910 the order here matters

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

very lastly we employ our own m.m's and i.m's -- which may be implemented as
#bundle-as-method-definition-macros -- because that is the most specific
thing of all in all of this (besides whatever the human client writes
in the client class). because we know that the outstream has added a
'method_added' listener, we turn the DSL off when our method macro adds
methods (which in theory shouldn't be necessary but feels nicer).

this is a concern that is relevant to everywhere that we employ bundles
after employing a DSL that uses a 'method_added' hook.



## :#storypoint-920

we may implement bundles as procs below. all of the ramifications of
[#121] the design pattern of "bundle as method definitions macro" must be
considered.



## :#storypoint-925 (method)

different than the other two (e.g) same-named instance methods that may be
defined in another DSL module elsewhere, this is a straightforward default
implementation of b.o.p that creates a stdlib o.p and runs any definition
blocks on it that you may have specified and adds a (hopefully) correctly
wired help option iff you didn't specify what looks like one ("-h") yourself
in one of your o.p definition blocks.

if your option parser has a special plan for the '-h' switch, the below
default help wiring won't trigger, so you might want to wire help differently
(e.g just '--help') and follow the below as a model.
