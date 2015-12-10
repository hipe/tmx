# the kernel narrative :[#015]

## synopsis

  • brazen-powered applications are "model-trees" (or "silo-fields"), with a
    "kernel" being the root of this tree

  • brazen-powered applications have to date never needed to subclass
    the kernel. it is a lowlevel mechanism that has no business logic.

  • the kernel is always one instance per application

  • the kernel is typically lazy-loaded and long-running

  • the kernel was merged with another component called "daemon"

  • the kernel cannot fail

  • the kernel never emits events directly




## introduction

the kernel exists to make the topmost node look like any other interface
branch node as necessary. it is pre-modality. it exists for modality-
specific clients to attach to and query for the data that makes up the
application.

as well it can be used by controllers to read "silo" shells for
other parts of the model.




## `fast_lookup` :A

this attribute (like all the others here) is meant to be written to only
at construction time. (it is a plain `attr_writer` only because it saves
the client from needing to write a subclass and/or us needing to maintain
a shell/kernel metaphor.)

if set to a true-ish value, that value should be proc-like.

the purpose is to provide the front client with an alternate algorithm
to be used as a first-try attempt at name resolution; an algorithm that
does not for example need to load (from the filesystem) many nodes just to
resolve one.

you might want to do this because;

  • it saves the resources of hitting the filesytem and then parsing &
    evaluating sibling nodes (perhaps all) at this level.

  • it may make for nodes that are less coupled to their sibling nodes,
    for better regression and more robustitude. (the one node can still
    work even if the other node for e.g employs a DSL that is not
    working at the time, for example during development.)

reasons that the client *would* need to load several nodes from the
filesystem include:

  • if you are using "promotions" the client needs to peek into every
    node at the current level to see if it promotes any of its children.

  • if you want fuzzy name matching, this is an aggregate operation that
    necessitates that the client stream over every node.

hypothetically a "fast lookup" can coexist cleanly with the above
points. (fast lookup should only implement exact match.) the client can
try the fast lookup first, and only after that fall back to the more
processing intensive aggregate operation.

(but come to think of it, #open [#014])

the sub-identifier of this subject is used to track client
implementations of this proc "in the wild."




## :#note-40

this is an area of some experimentation: the 'persist to' identifiers
hold both would-be "model identifiers" and "collection identifier" (e.g
database names). for readability (and fun) we munge these parts together
inline with the word-parts that a would-be model name might have (e.g
"git-config" as a collection name has the two parts, "git" and "config").

because these two concerns are munged into one name we need to do some
parsing to determine where the one ends and the other begins.

a year later we would try to abtract a general algorithm from this
as [#pa-002] for use elswhere. but currently its native implementation
is too entrenched, so for now thy exist separately but with the same
idea behind them.




## :#note-35

at the time of this writing this issue comes up when you run the
test-suite for [sg] before [br]. [sg] loads the walker node from the
workspace node of [br], which makes the workspace node "come out" before
the others do, which changes the order in which the autoloader reports
the constants as existing.

the order in which constants are reported in should be treated as
volatile and unreliable anyway, regardless of whether it is autoloading
or the runtime reporting the list of constants.

in this same vein, putting constants (or their respective referrants) in
a lexical (or other) order should probably not be a concern of the node
at this level. however it is easiest to put it here as a sane
normalizing fallback, since further down the pipeline we use scanners
and life is easier if the items "scan out" in the "right" (or any
consistent) order.

if we were crazy we would cache this sorted const list.

(what we end up doing is creating a linked-list style directed graph to
represent the desired order).




## :#note-265

although it is a class of use cases by which this whole algorithm was
inspired, currently this ambiguous state here only gets covered by
[sg]  (at this moment) by for e.g requesting the silo `node_collection`
(and there there are e.g 4 `node*` models). whew! that it works as
intended almost a year later.
