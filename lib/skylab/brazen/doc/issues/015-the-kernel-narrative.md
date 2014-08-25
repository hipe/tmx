# the kernel narrative :[#015]

## introduction

the kernel exists to make the topnost node look like any other interface
branch node as necessary. it is pre-modality.ity. it exists for modality-
specific clients to attach to and query for the data that makes up the
application.



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
