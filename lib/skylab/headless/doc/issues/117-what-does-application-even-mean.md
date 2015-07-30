# what does appilcation even mean? :[#117]

this is part of the [#br-098] disussion of ouroboros, which in turn is really
about trees of turtles.

disjoint thoughts for now, maybe this will be developed further later:


## scope of this node (statement of purpose)

• people have intuitive sense for what "application" (and more specifically
an "app") means generally. to try to define here formally is neither
useful nor interesting, so that is not our focus. our focus here is to
define the term within the context of the skylab universe, with emphasis
the facets of its totality as a concept that are noteworthy or uncommon.

• defined generally, we may say that an "application" is an aggregation and
alignment of software and services that has been coalesced into one apparent
coherent unit that provides a user interface (or interfaces) to access its
set of actions that it provides access to and interaction with.


## one factor is whether it is "distributable" as a standalone unit

from the perspective of the user, an application is something that appear
as a "stanalone" unit, one that may be "packaged" for "distribution".
(once upon a time it probably meant "the smallest amount of functionality
someone would be willing to pay for").

as we have seen and will continue to see, what constitutes a collection of
software suitable for "distribution" as a standalone unit is arbitrary in
the most formal sense. that it, it is a huge design decision, and one that
does not get made on its own.


## whether a node is an application may be very plastic and mutable

one key point is that the delineation of "application" is plastic and
mutable: what was once a "standalone application" might later become a
sub-node of another application (as happened with 'git-stash-untracked'
getting moved to live under the 'git' node).

outside of this universe a macro example of phenomenon is an "office
suite": what was once bundled and "shipped" separately as e.g a spreadsheet
application and a word processor gets re-conceived as a coherent unit.

presumably this reconception can go in the other direction, too. one of the
great skylab experiments is to see if we can make the mobility along this
axis more fluid.


## what determines whether an action node is an application is its sovereignty.

• another point to appreciate here is the sovereignty of nodes: in the skylab
universe we conceive of the application as a tree of nodes. each nodes is
either an "action branch node" or a "terminal action node". all such nodes
are referred to generally as "action nodes". the "application node" is
either a "terminal action node" or a "action branch node"; but one with
special skills we are trying to define here.

as we alluded to above, the application node may be a mounter, that is is may
be able to mount on to "under" a mountee application. that is, such a mounter
node can be conceived as being "broken off" and running standalone, or it
maybe be running has having mounted the mountee.

however not all nodes act as "mounters". the typical terminal action node
generally is not useful unless it is part of its parent branch node. (formally
we say that it has client services that it needs to operate). in this regard
it does not have "sovereignty" - that is, it cannot be easy run alone.

although even this distinction will break down with a powerful enough
microscope, we define "application" as any action node that has sovereignty,
that is, it can (given its dependencies) it can be run alone (presumably,
"alone" means given an adequate operating system and the necessary
dependencies, whatever they are, which again brings us back to the microscope.)


## what about modalities?

we have intentionally side-stepped discussion of modality here, in the hopes
that this definition can hold across modalities.


## ideas for the future

• in the future we may reconceive this slightly: in the same manner that OOP
was a reconception of procedural programming (if for nothing else then as an
at times useful abstraction to manage complexity, or at least to socially
engineer software architecture); we seek to rearchitect fundamentally our
conception as an application (or action branch node), as rather than being
a set of actions, being a set of business entity classes and business
interface entities classes. (these classes would in turn define a set
of actions)
