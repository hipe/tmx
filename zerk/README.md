# the zerk narrative :[#001]

## objective & scope

"zerk" is a goofy fun experiment for command-line apps. more broadly
it has become the standard-bearer for the broader dream (and theme)
of our universe, as introduced below at [#here.2].

the name "zerk" is a portmanteau of "zork" and "jerk"; "zork" out of
deference to the seminal text-adventure, and "jerk" just because.

"zerk" is meant to be a
  • modular
  • lightweight (out of the box)
  • reusable library
  • for making *interactive*, *command-line* programs.

as an unintended side-effect is has become an interesting alternative
means to make non-interactive API's as well.

also, non-interactive CLI's too.




## introduction to generated modality clients :[#here.2]

"generated modality clients" are the main thing that [ze] does. [ze] is
a sidesystem that is a vampire and (EDIT)




## introduction to the new edition

(TODO - #during [#009] write this)




## the fundamentals

zerk wants you to model your application as a tree of nodes.

(EDIT: this whole section is no longer helpful. say something about ACS
instead.)

ultimately you can implement a node to do whatever you want it to do
with the messages it receives from the zerk "runtime". in fact all it
may have to do is respond to an `execute` message.

but in practice our nodes typically act like the familar "branch node"
and "leaf node" from the graph theory of the tree data structure:

  • a zerk application must have one top node.

  • every node has one parent except the top node.

  • a "branch node" is a node with one or more children.

  • a "leaf node" is a node with no children.

for the simplest of nodes whose only job is to display and manage edits
to one data "field", there may exist an existing "model" to model such
things.

the fact that zerk likes to model the application as a tree-like
structure will be reflected in the default "top nav" rendering and
prompt rendering, which are intended to give the user a sense of "being"
within one node within this larger tree context at any given time, and
having the ability to navigate up and down the tree etc.




### the simple event loop

the running zerk application has a simple event loop:

1) the "current node" receives a request to render its panel, and
   presumably does so. (at start, the top node is the current node.)

2) then it (usually) blocks, waiting for the user to input something.

3) then once something is entered, the active node processes the input,
   does whatever it wants to do, maybe it changes the pointer that
   points to the active node to some other node in the tree (or
   perhaps a brand new node), maybe it even indicates that we are
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

in this way the user interface can be transformed by the current node:
the node can change what this "current node" is to one of its children,
or its parent (and sometimes even its parent's parent and so on #maybe).




### different potential "modalities"

currently zerk's main "modality" is what we call "interactive CLI" -
that is, it runs in the terminal interactively. but also:

  • one more mode that is supported is what we call `API`. the
    extent to which this will work "out of the box" depends on
    how much mode-specific logic is in your app..

  • (other would-be modalities are discussed under "wishlist" below)




## anti-wishlist

  • ncurses: we don't want it: somewhere in our universe we once used
    (and relied upon) `ncurses` for doing non-trivial stuff with terminals.
    then at some point it became difficult (broken for us) to build on OSX.
    whether or not this still remains the case, we have achieved the
    target level of usability here without it, so for now we believe it
    is best to avoid it altogether. (and if we do ever bring it back it
    should be spun off as its own library.)




## wishlist

  • in effort to simplify, we removed the automatic session
    serialization (storage to disk) we used to do. we *might* bring
    it back if ever it hurts too much not to have it.

  • one day it would be nice to have partial non-interactive CLI
    support: you could enter many values in the familiar POSIX utility
    conventions, and it would "drop you in" to a screen with those
    values populated, and/or run the "job". but this will require some
    design.
