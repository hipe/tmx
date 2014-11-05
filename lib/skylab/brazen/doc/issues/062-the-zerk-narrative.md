# the zerk narrative :[#062]

## introduction

the name "zerk" is a portmanteau of "jerk" and "zork"; "zork" out of
deference to the seminal text-adventure, and "jerk" just because.

"zerk" is meant to be a
  • modular
  • lightweight (out of the box)
  • reusable library
  • for making *interactive*, *command-line* programs.




## roadmap

• when we figure out what we are doing, boy wouldn't it be great if this
  were automatic like [br] CLI, and then you could flip-flop etc.

• it does not yet use ncurses, but if we were to approach that we would
  want it to do so unobtrusively, or spin off a separate library.




## the fundamentals

zerk wants you to model your application as a tree of nodes. for now we have
dubbed these nodes "agents". each of these nodes typically acts like a
"branch node" or a "leaf node" but ultimately you can implement a node
to do whatever you want it to do with the messages it receives from the
zerk "runtime".


the running zerk application has a simple event loop:

1) the current agent receives a request to render its panel, and
   presumably does so.
2) then it (usually) blocks, waiting for the user to input something.
3) then once something is entered, the active agent processes the input,
   does whatever it wants to do, maybe it changes the pointer that
   points to the active agent to some other agent in the tree (or
   perhaps a brand new agent), maybe it event indicates that we are
   done. but if it doesn't indicate this, it goes back to (1).


branch nodes can access their children, and any node can access its
parent, and even its parent's parent, and so on. (the root node's parent
node is the entrypoint application, for now written entirely by you.)

in this way the user interface can be tranformed by the current agent:
the agent can change what this "current agent" is to one of its children,
or its parent (and sometimes even its parent's parent).





## fun feature: persistence

both as an exercisize and out of convenience, we play with the idea of a
"form" (a branch node) having "sticky" values that persist between
invocations of the application.

for now this is done by writing the form's state to a simple text file
using our "git-config" library, which seems to work well enough.

for now we re-write the "entire" text file each time the user enters a
new valid value for a leaf node, which is convenient for us preserving
the most recent state even if our application throws uncaught exceptions
during development. but this may change.





## using it

we don't make it too easy for you out of the box, so that down the road
hopefully you don't feel like you're wrestling against the framework:
what zerk *does* try to give you is tools for driving a simple
terminal-based UI; but what zerk does *not* concern itself with is:

  • how your leaf datapoint is displayed
  • how your leaf datapoint is stored in the node's ivar(s)
  • how your leaf datapoint is marshalled to disk (or network)
  • how your leaf datapoint is unmarshalled from disk (or network)

for now, we don't even provide out-of-the-box defaults. for each of your
leaf classes you will have to make these decisions for yourself. this is
largely because that so far, with our frontier application it has proven
futile to try and assume any defauls for these, given how polymorphic
our data fields are.




## :#note-222

relying on the hook-out method to result in a pair structure rather than
just relying on a `marshal_dump` being defined lets us pack more meaning
and usefulness into the hookout.

this way the marshaling valuespace is wide open, and we aren't stuck
wondering if a false-ish value from the method means "don't persist" or
means "this is the marshalled value".

agents that never persist can simply define the hook-out method with an
empty body. this is better than doing this with `marshal_dump` would have
ambiguous semantics.
