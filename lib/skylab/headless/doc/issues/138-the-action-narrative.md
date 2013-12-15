# the action narrative :[#138]

:#storypoint-1

**NOTE** *any* public methods defined below are very #experimental while we
decide what the set of `public` should be for is for and how action objects
(in their many various incarnations) are used here..



:#storypoint-2

"branch" means "non-terminal" means "box". because it has far reaching
consequences for request processing, awareness of branchiness is baked-in
deep. it is recommended that you *not* redefine this anywhere universe-wide,
and rather hack "is leaf" instead if you nead to, for reasons. (it is this
way and not the reverse for reasons.)

out of the (heh) "box" we assume we are a terminal action and not a box
action.
