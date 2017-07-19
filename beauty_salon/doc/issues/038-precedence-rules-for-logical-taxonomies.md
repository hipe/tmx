# precedence rules for logical taxonomies :[#038]

(EDIT: this whole document is now antique, belonging to the [br] era)




## the purpose and scope of this document..

..is to present the concept of "node" and "taxonomy", and then the concept
of "axis" on top of them. we then enumerate all known axes and then propose
an order of precedence for those axes.




## understanding the meaning of "node" in this context

the entire skylab universe fits under one toplevel ruby module called
::Skylab. all of its applications and in turn their support libraries
(both collectively referred to under the umbrella term "sidesystems")
live directly under this module.

(we dervied the term "sidesystem" from the term "subsystem", a term that
we borrowed from Apple's Cocoa universe. we may occasionally use the two
interachangeably here, but nowadays we try to use the term "sidesystem"
exclusively.)

logically this whole thing makes one giant tree, a tree that we may
refer to as the "skylab taxonomy".

so in the general case, when we speak of a "node" in the context of a skylab
taxonomy we are speaking of some ruby object that exists as a constant
somewhere in this tree of constants, whose rootmost node is the toplevel
module Skylab.

the reason we say "node" and not "module", "class" or "constant" is twofold:
for one, "node" encompasses all of these meanings without specifying
specifically which is meant. this is done intentionally because often a node
that was once a class then becomes a module, or a node that was once a module
gets reduced down to a simple enhancer proc; or the other direction, etc.
by saying "node" we emphasize that the particular shape of the node is not
important; that what we are emphasizing it where it fits taxonomicaly into
the larger hierarchy without having to think about the unimportant detail
of its particular shape.

a second, more general reason we like the term "node" is because it evokes
graph theory and maybe even trees; and this frame of mind is useful when
speaking of the skylab taxonomy for reasons we may explore below.




## case study: how we store and represent "proxies"

what we do with proxies is an interesting case study because we make
proxies everwhere...




(EDIT: content below the line is historical and has not yet been merged in.)

-----

## the axes enumerated

in the skylab universe we will speak of "axes" (as in the plural of "axis",
not "axe"). they may be thought of as "aspects", probably always aspects for
nodes.

one important axis that we touched on already above is that of "subsystem."
very early in the life of skylab we made the design choice that each part of
the skylab project would fit into one of a possibly infinite list of
subsystems that would be conceptualized to "live" side-by-side to one another
under the ::Skylab node. (they are meant to be amenable to the possibility of
being refactored only slightly and then "shipped" alone as their own ruby
gem where optimal.)

the "headless" subsystem in its entire conception and development has always
been a celebration of what has become another important axis: "modality."
as we write this, headless is an unfinished experiment in the notion that
clients for different modalities can be generated from the same core API,
sufficiently indexed. the idea is somewhat like Java's "Swing", but even
more ill-founded. the main modalities we work in now are things like "CLI"
and "API", but these are just training wheels for the ultimate goal of the
project.

support for the "CLI" had existed in skylab before the notion that a "CLI"
could be isomorphic to an interface for another modality. also, once we
developed support for another modality (namely, the "API"), we started
looking for ways that we could re-use the names for different parts of these
support libraries accross modality where appropriate. we have formalized this
idea by calling it an "axis": "component."

so for example, both the "CLI" and "API" modalities have these "components":
client, action, etc.

something we started doing a few months before the idea of "bundles" really
jelled was something similar: "facets". a "facet" is a collection of code
related to one feature or a group of related features, usually one that was
loaded all at once & lazily (on-demand). we may now see individual "facets"
(as a logical unit) that are comprised of multiple bundles. anyway, "facet"
is itself an "axis".

(as well there are (perhaps unrelated) [#080] other treatments
of this term "facet".)


## a precedence order proposed

the preceding section introduced four axes: "subsystem", "modality",
"component", "facet". we now develop a "precedence rules" among these
to pertain to "nodes", and explain what is meant by this.

above we presented that all nodes of the skylab fit into a tree structure,
with "skylab" as the root node of this tree and one immediate child-node
of this root node for every subsystem. therefor if you know what subsystem
your node(s) fit into, it is almost a tautology that you know the node
under which (at some yet-to-be determined depth and path) your node(s) will
live. so we will exclude "subsystem" from the rest of the discussion.

every subsystem will maintain its own taxonomy, but the following "rules"
are proposed as guidelines for these taxonomies.

it is anticipated that where "modality" fits into taxonomies will be in flux
in the forseeable mid-term future; hence we will sidestep discussion of this
axis for now. suffice it to say, take as given the way modalities fit into
any current subsystem taxonomies, but know that they might change.

this leaves us with two axes: "facet" and "component". so it appears that
this entire essay was constructed to present a list of rules of precedence
with two items. this list is as follows: 1) facet. 2) components.

this means that the axis of "facet" "binds tigher" to a node than the
axis of "component", so if ever you hit a fork in the road where you are
trying to place a node under one of two competing nodes, and those nodes'
facets are one of these two, chose 1 over 2.

the reason for this is that we want the axis of "facet" to "feel like"
plugins - we anticipate this to be a greater area of change than the axis
of "component". (we anticipate that we will add facets more frequently than
we will add/rename/remove components.)

that is all.
