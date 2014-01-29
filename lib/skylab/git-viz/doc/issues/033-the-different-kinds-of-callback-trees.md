# the different kinds of callback trees :[#033]

## statement of scope and purpose of this document

there are currently three callback patterns we want our "callback tree"
to support. the document hopes to delineate their differences as a means
of speculating the feasibility of integrating them into one tree.


## the callback tree structure and story in general

the rationale behind this is that we can grow flexible, relatively easy to
maintain and extend architectures by creating a small core "host" application
that exposes "channels" that "listeners" can subscribe to, and then as the
host runs it emits "events" (or "eventpoints") on these channels, on which
the listeners get notified of the events. in some cases the host (or callback
tree itself) will take different actions based on the result of the callbacks.

the "host" can be any object that accepts listeners to channels, and
presumably then emits events at various points in its lifecycle.

the callbacks are concrete, callable proc-likes that represent the more
abstract notiong of a corresponding "listener" behind them, which is to say we
may use these terms somewhat interchangeably. (but note that what actually
happens when the callable is called is unimportant from the perspective of the
host, except for in some cases the result value of the call, which will be
explained below.)

listeners subscribe to "channels": in this system the different kinds of
events that can be emitted by the host are organzied in a taxonomical tree
structure (like files in a filesytem). the host defines this tree and
listeners subscribe by referring to paths in that tree.

hypothetically listeners could subscribe to non-terminal "branch" nodes in
this tree (the equivalent of directories in the filesystem analogy) and
thereby be subscribing to all the child channels of that node; but this is not
necessarily implemented depending on the kind of callback tree it is.

"events" may be accompanied by an object (like an exception, or a string, or
any other mixed kind of data); but also it is perfectly acceptable not to pass
event data along with an event depending on what is needed. sometimes just the
occurrence of the event itself (on its particular channel) is enough
information for the listeners to react accordingly.

we may say "eventpoint" instead of "event" either to refer to an event that
has no data passed long with it; or an event that only occurs once during the
lifecycle of the host object; we are not sure which.



## the different callback patterns in brief

currenly we employ three different patterns for accepting callbacks and in
turn handling their responses. this document exists to guide their attempted
integration into one tree. we even considered (gulp) a plugin architecture
for callback trees, but to introduce such a monstrosity now would certainly
be premature albeit fun.

the three patterns are "listeners", "handlers" and "attempters".

• "listeners" are just plain old proc-likes that get called whenever the host
  deems it has reached that particular eventpoint. whatever their result is
  is ignored by the host, so multiple of them may be associated with any given
  channel.

• "handlers" are nodes who rather than manage sets of listeners for each
  channel, allow at most one callback per channel (think of them as "slots");
  with ramifications discussed below.

• "attempters" allow multiple callbacks per channel, and will issue each such
  event to them in some order (probably last-in-first-out), and short-circuit
  on the first callback that "matches".



## the feature matrix

                    multiple?   inherits?   result matters?
listeners pattern         yes          no               no
handlers pattern           no         yes              yes
attempters pattern        yes         yes              yes



## the "listeners" pattern in detail

• this is the simplest of the patterns

• one such event will be dispatched outwards in two dimensions: "laterally"
  to any listeners listening to that channel, and then "upwards" to each
  parent channel of the channel, and on that node "laterally" out to any
  listeners of that (branch) channel.

• results of callbacks are ignored. they never have an impact on the behavior
  of the host (or the callback tree).

• if a client subscribes to both a more general and more specific channel;
  when an event fires on the specific channel, both callbacks will be invoked
  in order from specific to general.


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

• the one most essential and central difference from a listener tree is a
  corollary of the above: given that we get one meaningful result back from a
  callback (rather than an aggregate of results from several callbacks); we
  can use that one result to drive the remaining logic of the agent. always
  the pattern is this: if a true-ish is resulted from the callback, it is
  taken to be an error code. the agent typically ceases further processing to
  whatever extent is appropriate and the error code (or a translated
  equivalent error code) is bubbled all the way up and out of the agent, and
  returned as the result of the top call to that agent.

• a corollary of the above is this: not only can the client drive the agent
  by effectively short-circuiting its operation by resulting in an error code
  thru a callback; likewise the client can tell the agent to keep going where
  normally it would have stopped.

• it remains to be "proven", but the author suspects this is more powerful
  than the exception model for certain techniques. it is nonetheless the
  author's opinion that this technique is less clunky and less ugly than
  exploiting exceptions for similar behavior.

• yes it is definitely more powerful: the tree that the handlers define adds
  an extra dimension. now the semantic taxonomy is divorced from the class
  taxonomy. handler trees can glom from other handler trees.

• given how much dramatic sway the client can have on the agent's behavior
  (depending on how the agent is written and how the client builds (or sets)
  the handlers), it starts to feel like a powerful little dependency injection
  pattern. (we can imagine marionette strings between the client and the agent.)



## the "attempters" pattern in detail

# #todo:2-commits-from-now



## issues in integrating all of them into one tree

.. are anticipated.
