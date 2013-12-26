# workflow patterns :[#137]


## the golden two-step :[#136]

this is an at-the-time-of-this-writing an imaginary maneuver consisiting of
this: in one pass you muscle through your topic, laying down a trail of
desctruction on top of stable nodes. you do whatever you have to do to get
your topic green while keeping the universe green.

then, the second step is this: you write your history to make it look as if
you did this in two steps: break out the part of the changes that have to
do with the universe, and then in one more commits integrate the changes into
the universe while keeping everything green, maybe even adding tests. then in
the second step you integrate your topic.

maybe this is only practical to do when you are re-greening a subsystem, as
opposed to maintaining it.

then in a subsequent commit (the "two" of the "golden two-step") you lay
down a commit (or more) that integrates your topic subsystem into the mix,
on top of the new universe changes you made.


### the point of this maneuver

the point is that it looks sloppy to have universe changes mixed in with
your topic changes. it is more courteous to the future to force this changes
into two or more steps, to make the narrative more clear.


### cons:

this will become a quagmire unless the scope of your step is relatively small.
