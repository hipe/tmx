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

zerk wants you to model your application as a tree of nodes. for now we
generally call these nodes "agents".

ultimately you can implement a node to do whatever you want it to do
with the messages it receives from the zerk "runtime". in fact all it
may have to do is respond to an `execute` message.

but in practice our nodes typically act like the familar "branch node"
and "leaf node" from the graph theory of the tree data structure:

every node has one parent except the root node (or in our case the root
node's parent may be the entrypoint application.) a "branch node" is a
node with one or more children. a "leaf node" is a node with no
children.

for the simplest of nodes whose only job is to display and manage edits
to one data "field", we may prefer this term 'field' to the more general
term "agent", which carries some relatively heavy connotations in
computer science.

the fact that zerk likes to model the application as a tree-like
structure will be reflected in the default "top nav" rendering and
prompt rendering, which are intended to give the user a sense of "being"
within one node within this larger tree context at any given time, and
having the ability to navigate up and down the tree etc.


### the simple event loop

the running zerk application has a simple event loop:

1) the current agent receives a request to render its panel, and
   presumably does so.
2) then it (usually) blocks, waiting for the user to input something.
3) then once something is entered, the active agent processes the input,
   does whatever it wants to do, maybe it changes the pointer that
   points to the active agent to some other agent in the tree (or
   perhaps a brand new agent), maybe it even indicates that we are
   done. but if it doesn't indicate this, it goes back to (1).

the event loop checks if each result from each call to `execute` is
false-ish, and if so we break out of the loop and presumably exit the
application.

note if your node does an `execute` that neither blocks for user
input nor changes the "current node" pointer nor results in false-ish,
the event loop will infinite loop rapidly, which is probably not what
you want.


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




## :#note-190

in practice so far, in our frontier application the constituency of nodes
that makes up a branch node's "item listing" and/or "downward links" prompt
at any given moment is "somewhat dynamic": any individual child node may
variously be or not be executable based on the arbitrary internal criteria
about the system's state at that moment.

so far it's seen as a fun time-saver (and a proof-of-concept experiment
playground field-day of [#br-063] isomorphically emergent interfaces) to
go hog-wild with interface generation here:

1) the node by default derives its name function from its class name.

2) the node derives its label (what appears in the UI)
   from its name function.

3) the node derives its "hot keys" (the shortest head of characters
   that is locally unique within this branch node) from the other nodes
   that are executable at that moment. this is what lead to
   what we are for now calling [ba] "determine hotstrings".




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




## :#note-branch

a branch node

  • has children nodes
  • has visual representation when interactive
  • consumes upstream input, blocks when interactive
  • does not have a value of its own
  • does not itself persist, but helps children marshal and unmarshal

the branch node's main purpose is as a creator of a namespace (useful
for both interactive and non-interactive modes) and (when interactive)
a way to break large "forms" into smaller "forms".




## :#note-fields

a field node

  • does not have children nodes
  • has visual representation when interactive
  • consumes upstream input, blocks when interactive
  • has a value that is known or not known
  • may persist per implementation

the field must be implemented by the application to take user- or
marhshalled data and convert it (as possible) to an internal
representation. there is as yet no out-of-the-box support, for example,
for a simple string field because one has not yet been useful to have on
its own.




## :#note-button

currently "button" does not have formal representation in the code
other than the fact that some node classes include the word "button" in
their name. despite this the following criteria *must* be met and the
following considerations should be taken into account to call anything
a "button" in a zerk mezo-interface:

a button node

  • does not have children nodes
  • has visual representation when interactive
  • consumes upstream input *only when interactive*, never blocks
  • does not itself have a value
  • hence does not persist

currently a button exists only to drive program flow (e.g navigation)
and must have significance only for interactive modes. otherwise (in
the non-interactive mode) it must be that every button exist vestigially
but is not required for operation and must never be reachable (the
framework will be built for this: do not use or support the use of button
names anywhere in non-interactive requests.)

the only known classes of button that exist currently are "up" and
"quit". neither of these are useful (or used) in non-interactive modes.

a "boolean node" (described below) "feels like" a button in how it
manifests in the UI (for interactive mode) but is categorized
differently because of its a) relevance to the non-interactive mode and
b) the fact that it is part of a composition that (unlike a button) has
a value that can be persisted, etc.




## :#note-bool

a boolean node

  • does not have children nodes
  • has visual representation when interactive
  • consumes upstream input but never blocks
  • has a value that is known or not known
  • may persist currently only thru an "enumeration group"
  • its value when known is either `true` or `false`, making it a special
      kind of "tagged union" of "unit type" of type theory; or
      "enumerated type" in computer science.

currently boolean nodes are only used to implement "enumeration group" (see).
this was formerly called "toggle', named after one way we see this sort
of field manifest in GUI's. (another such surface representation in
another modality is as a "flag".)




## :#note-enum

an enumeration group

  • has children nodes effectively (but this may not be relevant)
  • does not itself have visual representation (its constituents do)
  • does not itself consume upstream input, and so never blocks
  • has a value that is known or not known
  • has a persistence implementation
  • currently, its value when known is a symbolic representation of which
    one of its children is "activated"

this is an implementation of what we know as an "enumerated type" in
computer science or (maybe?) a "sum type" in type theory. we see this
sort of field manifest in GUI interfaces variously as "radio button" groups
or "selects" ("drop-downs") (the common kind that lets you chose only one
of its elements); among perhaps other surface representations.

we implement this (and conceive of it) in what may seem like a strange
way: we see an enumeration as a grouping of boolean nodes whereby only
one of those nodes may have the "true" value at any given time (and
possibly none of them have it).

(this isomorphicism is further explored in "the axiom of binary
convertability" in [#it-003]: an enum field may be represented generally
and losslessly as a group of boolean fields whose truth is mutually
exclusive, and the converse is true; hence they are two different
surface representations of a deeper structure.)

we will refer to the one boolean node that has the true value as having
been "activated".

as for implementing persistence for this whole grouping, it is convenient
(if somewhat awkward) to implement it this way: the boolean nodes
themselves do not persist individually. they effectively report up to this
parent node when their value changes, and so the parent redundantly keeps
track of which node is activated. to persist all possible (valid) states of
this grouping it is only ever necessary to represent which particular
child (if any) is activated. we do this with a symbolic (string)
representation of the activated child node using its normal name, and we
can likewise unmarshal the grouping's state thru this same means.

this is why this group structure is itself modeled to "look like" a node:
to the branch parent that persists this node reports a persistence pair
just like any other persisting child ("field") does: it gives its own name
for the group and for its value it gives the symbolic name of the activated
node. (when no child is activated, it results in `nil` for the pair
message.)
