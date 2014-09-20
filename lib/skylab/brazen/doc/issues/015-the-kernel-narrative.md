# the kernel narrative :[#015]

## introduction

the kernel exists to make the topnost node look like any other interface
branch node as necessary. it is pre-modality. it exists for modality-
specific clients to attach to and query for the data that makes up the
application.

as well it can be used by controllers to read "silo" shells for
other parts of the model.



## :#note-40

this is an area of some experimentation: the 'persist to' identifiers
hold both would-be "model identifiers" and "collection identifier" (e.g
database names). for readability (and fun) we munge these parts together
inline with the word-parts that a would-be model name might have (e.g
"git-config" as a datastore name has the two parts, "git" and "config").

because these two concerns are munged into one name we need to do some
parsing to determine where the one ends and the other begins. since the
way the cards have fallen we don't actually need this logic yet, but we
ceratainly will if we keep this up.





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
