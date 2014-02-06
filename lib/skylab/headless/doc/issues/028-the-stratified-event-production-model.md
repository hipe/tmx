# the stratified event production model :[#028]

to explain the model we put it int terms of CLI because that is what is
familiar, but the deeer principles behind this will hopefully hold accross
modalities.

the original focus of ths essay was the "stratified even prodcution model",
but it is more fun if we start out the narrative with the typical input
events, and travel downwards and then work our way back up:

## 1. the trip downwards

 +----------------------+            1. for the context of the CLI utility
 | the modality context |            with regards to input, this layer consists
 +----------------------+            of the operating system and shell that
           |                         invoke the interpreter (ruby) and the
           |                         interpret the command-line application.
           |
           |                         the "output shape" from this layer to
           |                         below is e.g ARGV and stdin. we may dub
           |                         the latter as a "service" but it's also
           |                         a substrate for input.
           V
  +---------------------+            2. the modlity client attempts to resolve
  | the modality client |            one action from the ARGV, implements
  +---------------------+            UI behavior if it cannot; otherwise it
           |                         dispatches the mutated ARGV downwards.

(the client may also forward the "service" of STDIN downwards, by exposing
it (or a filtering proxy around it) as a service of its own available to the
instream agents. similarly stdout and stderr can be made available as services
but this should be done only as necessary.)
           |
           |                         3. unbeknownst to it, the "modality
           |                         action" is constructed by the client
           V                         and gets passed a "client" (services pxy)
    +-------------------------+      in its contruction. it gets sent an
    | the modality sub-client |      "invoke" message in which is passed
    | (e.g action, agent)     |      an input with a shape of "ARGV".
    +-------------------------+      not always but often the modality
                |                    action implements itself solely by
                |                    invoking a sister API action.
                |
this sister API action that is constructed will be invoked with some kind
of structured request structure, typically a structure of name-value pairs,
perhaps an "iambic" list of tagged input. so one respsibilty of the madlity
client is to transform the request from ARGV into this structure.
                |
                |                    it would be best to construct the
                v                    API object only with a listener object
      +-----------------+            and the request structure (name-value
      | an API Action   |            pairs). if services will be required
      | (also an agent) |            then room should be made to pass a
      +-----------------+            "client" proxy around these too.

the API action's "execute" method is where the real work happens. more often
now we are trending towars API models, so the API action may dispatch the
request (perhaps modifed) to a business entity in the model, but the
principles outlined here will still hold.

so, whether the API action *is* a busiess entity, or dispatches the request
to one, etc; we can imagine that this layer represents all of these. for
now we will omit the rest of the details downwards.


## 2. the trip back upwards

because our focus here is the lifecycle of an output event, and output events
events tautologically bubble from the inside out (i.e from downwards up),
the story below starts and the bottom and works its way upwards. (so please
start reading from the bottom below at #1).

 +----------------------+            5. the modailty context provides UI/
 | the modality context |            IO services, in the case of the command-
 +----------------------+            line they are e.g the three streams.
          ^ v
  +---------------------+            4. the services exposed by the modality
  | the modality client |            client could be limited to just
  +---------------------+            "call_digraph_listeners info line" and "call_digraph_listeners payload line"
            ^ v
    +-------------------------+      3. this is where the event is prepared
    | the modality sub-client |      for modality-specific presentation /
    | (e.g action, agent)     |      articulation. the event is received on one
    +-------------------------+      of the semantic channel listener methods,
              ^ |                    parent cilent services are called with
              | |                    new modality-approiate "events". either
              | |                    hand-written or transformed procedurally
              | v
      +-----------------+            2. the API action having received the
      | an API Action   |            event from the sub-agent may pass it
      | (also an agent) |            through as-is upwards in an identical
      +-----------------+            manner, or it may absorb/alter it.
             ^ v
   +-------------+                   1. some arbitrarily deeply nested sub-
   | some "verb" |                   agent (if it sees that a listener is
   | sub-agent   |                   listenging to the appropriate semantic
   +-------------+                   channel) builds and emits a custom,
                                     structured [#132] Event-like object.

well that's a start.
