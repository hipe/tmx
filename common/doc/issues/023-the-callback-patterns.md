# the different kinds of callback tree patterns :[#023]

## statement of scope and purpose of this document

(EDIT: this document is now subsumed by [#001]).

there is a variety of callback patterns (at least four) that we want our
"callback tree" to support. the document hopes to survey them one by one and
with each pattern: explain its behavior, present potential applications for it
(when interesting), and finally to highlight the differences among the
patterns as a means of speculating the feasibility of integrating them into
one tree.




## the callback tree structure and story in general

the rationale behind this is that we can grow flexible, relatively easy to
maintain and extend architectures by creating a small core "host" application
that exposes "channels" that "listeners" can subscribe to, and then as the
host runs it emits "events" (or "eventpoints") on these channels, on which
the listeners get notified of the events. in some cases the host (or callback
tree itself) will take different actions based on the result of the callbacks.

the interplay between the host and the callbacks is where it gets really
intersting, but first we offer some rough working definitions for all the
components and concepts at play here. (sadly the definitions are somewhat
circular, but there was no easy way "around" this!)

the "host" can be any object that accepts listeners to channels, and
presumably then emits events at various points in its lifecycle. typically
one or many "agents" will subscribe to these channels. depending on the
pattern specified for the channel, either one or many agents may
enlist/subscribe into that channel.



### the shape of the callback

the callbacks may be concrete, callable proc-likes that represent the more
abstract notion of a corresponding "listener" behind them, which is to say we
may use the term "callback" and "listener" somewhat interchangeably.

alternately the callbacks may be symbolic references (e.g ::Symbol's) that
"point to" some object somewhere that will be used as a callback. facilities
exist below for some callback patterns to support the front half of this, but
the host must implement its own de-referencing of these "callback references"
into actual objects that make the calls (see the "plugin" subsystem, wherever
it is now).

but with these various shapes of callback note that whatever actually
happens when the callable is called is unimportant from the perspective of the
host, except for in some cases the result value of the call, which will be
explained below.



###  the agent enlists/subscribes to "channels" of the host, and gets "events"

listeners enlist/subscribe to "channels": in this system the different kinds of
events that can be emitted by the host are organzied in a taxonomical tree
structure (like files in a filesytem). the host defines this tree and
listeners subscribe by referring to paths in that tree.

hypothetically listeners could subscribe to non-terminal "branch" nodes in
this tree (the equivalent of directories in the filesystem analogy) and
thereby be subscribing to all the child channels of that node; but this is not
necessarily implemented depending on the pattern being employed.

"events" may be accompanied by an object (like an exception, or a string, or
any other mixed kind of data); but also it is perfectly acceptable not to pass
event data along with an event depending on what is needed. sometimes just the
occurrence of the event itself (on its particular channel) is enough
information for the listeners to react interestingly.

when we say "eventpoint" as opposed to "event', we may be referring to
either an event that has no data passed along with it, or an event that only
occurs once during the lifecycle of the host object; we are not sure which.




## #the-different-callback-patterns-in-brief

currently we employ the below "several" patterns for accepting callbacks and
in turn handling their responses. this document exists to guide their
attempted integration into one tree. we even considered (gulp) a plugin
architecture for callback trees, but to introduce such a monstrosity now
would certainly be premature albeit fun.

the five patterns are "callback", "listeners", "handler", "shorters",
"reducers".

• "callback" is the simplest: for a channel designated as "callback", at most
  one listener proc-like can be associated with it. if the host uses what is
  currently the only method available for invoking such a .. ahem .. callback,
  then it is something like a required field for the host: it is assumed always
  that it was set by the caller agent.

• "listeners" are just plain old proc-likes that get called whenever the host
  deems it has reached that particular eventpoint. whatever their result is
  is ignored by the host, so multiple of them may be associated with any given
  channel.

• "handler" is the pattern whereby at most one listener agent may "enlist"
  into the "slot"-like spot. the tight specifications are discussed below for
  what kind of events may be emitted into such a channel, and the logical
  repercussions of the result that the agent gives back to the host here.

• "shorters" allows multiple callbacks per channel and short-circuits on
  the first one that results in true-ish, making this result be the result of
  the call to the callbacks tree. more below. :#shorters

• "reducers" is not implemented, so we won't bother explaining it.




## the feature matrix

                    multiple?   inherits?   result matters?
callback pattern           no          no              yes
listeners pattern         yes         yes               no
handlers pattern           no         yes              yes
shorters pattern          yes          no              yes




## :#the-callback-pattern in detail :[#040]

• this is the simplest of the patterns

• typically the host has one "agent" which is the caller, and the caller
  sets the callback(s) to event handlers that handle events appropriately
  for that "client-agent".

• whether or not the result of the callback will affect the behavior of the
  host (or merely constitute its return value, or not) is determined by how
  the host is written.

• in the interest of simplicity as a design goal, currently there is no
  built-in facility for determining if any particular callback proc-like has
  been set or not

• so effectively a "callback"-style node in a callback tree is always a
  required field.

(EDIT: this whole document will probably be archived, but while we are
here, note that we draft a proper indictment of the above pattern in a
commit message from this time..)




## :#the-listeners-pattern in detail

• this is the second simplest of the patterns, next to "callback"

• one such event will be dispatched outwards in two dimensions: "laterally"
  to any listeners listening to that channel, and then "upwards" to each
  parent channel of the channel, and on that node "laterally" out to any
  listeners of that (branch) channel.

• the order that the callbacks are called in "laterally" at any one level
  is undefined, but note that "vertically" the order is from "bottom" to
  "top", so when you have a deep tree (and not just a flat list of channels)
  the more specific channels are called first before the more general ones.

• results of callbacks are ignored. they never have an impact on the behavior
  of the host (or the callback tree).




## the handlers pattern in detail

• the data payloads that these callbacks are passed are necessarily
  exceptions.

• when no callback is resolved for an exceptional event, handling of it falls
  back to the default-most handler as implemented by the listener class which
  in this case is to raise the data payload as an exception (hence the
  previous point: as long as this is true the data payloads must always be
  exceptions).

• one (terminal) event channel may only be associated with at most one (proc-
  like) event handler. this is a corollary to a below point.

• the responses from these callbacks are taken to be error codes. their
  absence (that is, any false-ish result) is taken to mean that the error (i.e
  "exceptional event") was handled.

• the one most essential and central difference from the listener pattern is a
  corollary of the above: given that we get one meaningful result back from a
  callback (rather than an aggregate of results from several callbacks); we
  can use that one result to drive the remaining logic of the host. always
  the pattern is this: if a true-ish is resulted from the callback, it is
  taken to be an error code. the host typically ceases further processing to
  whatever extent is appropriate and the error code (or a translated
  equivalent error code) is bubbled all the way up and out of the host, and
  returned as the result of the top call to that host.

• so in this scenario the "things" behind the callbacks are no longer passive
  "listeners" but in fact they are active "agents", taking part in determining
  the behavior of the host.

• a corollary of the above is this: not only can these agents drive the host
  by effectively short-circuiting its operation by resulting in an error code
  thru a callback; likewise the agent can tell the host to keep going where
  normally it would have stopped!

• it remains to be "proven", but the author suspects this is more powerful
  than the exception model for certain techniques. it is nonetheless the
  author's opinion that this technique is less clunky and less ugly than
  exploiting exceptions for similar behavior.

• yes it is definitely more powerful: the tree that the handlers define adds
  an extra dimension. now the semantic taxonomy is divorced from the class
  taxonomy. handler trees can glom from other handler trees.

• given how much dramatic sway the agent can have on the host's behavior
  (depending on how the host is written and how the agent builds (or sets)
  the handlers), it starts to feel like a powerful little dependency injection
  pattern. (we can imagine marionette strings between the agent and the host.)




## :#the-shorters-pattern in detail

• this is something like a broadening of the "handler" pattern: it adds power
  in one dimension and we lose power in another.

• multiple callbacks may be associated with one channel. they are called
  in some order (either defined or not, preferably it wil be defined);
  and if any first callback results in a true-ish, it will be taken to be
  something like an error code.

• when such an error-code-is is resulted, further processing is
  "short-circuted" (hence "shorters"), and this error-code-ish is the result
  of the original call to the callbacks tree.

• this is the way in which "handler" pattern is more powerful than this one:
  with handler pattern, the host can write itself such that the handler
  would override something that would normally be an error and instead
  take some alternate action (sort of like a 'rescue' clause in ruby, or
  'catch' clause in most other languages). with "shorters" pattern we lose
  this.

• we take a discrete view of channels here: we do not deal with ascending
  up the "ancestor chain" of parent nodes in the tree, because that would
  make things confusing and weird.




## issues in integrating all of them into one tree (:#storypoint-200)

..are anticipated:

at present no type assertions are performed explicitly to ensure that the
callback pattern being invoked on the channel correspond to the callback
pattern that was specified for that node when the tree was built.

when we are lucky, in such cases the call will fail loudly because depending
on the pattern being attempted the node may not have the correct shape; but
this is not guaranteed.

for example, a "handlers" node has a different shape than the "listeners",
so to try to call listeners as if they were a handler will raise a runtime
no method error.

but there is crossover that is not yet fully established for the requirements
of the underlying structures necessary to support the various higher-level
patterns specified above:

for all practical purposes shorters
and listeners could all be implemented with the same class and as such the
same set of callbacks could be treated either as passive listeners or active
agents depending on how you call them and what you do with the result.

if this ever becomes an issue we will add an extra type-check somewhere
but for now in the spirit of experimentation this is left as-is.




## :#storypoint:50

this is an #experimental hack to let a polyadic node quack like a monadic node
for the purposes of using a mutable shell.

consider that all available "write" operations on any mutable shell are
always of the "set-foo" and not of the "add-foo" variety: you are always
setting a proc for a particular channel, you are never adding a proc to a set
of procs. we intend to keep it this way as long as it is practical to.

if no proc-likes have yet beed added to this node, the node accepts the
argument proc and results in true-ish indicating success. alternately if the
node already has one or more procs associated with it, the result is false-ish
and no further behavior is reified.

the caller bears the responsibility of reacting appropriately in such
circumstances.
