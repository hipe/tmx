# model-centric operator branch :[#011]

## synopsis

perhaps the most ambitious-yet implementation of a [#ze-051]
"operator branch", one that attempts to shoehorn the massive collection
of architectural conventions of [br] "reactive trees" into the minimal
interface of an operator branch..

the subject (in its current incarnation) was born to assuage the PLETHORA
(14?) of sidesystems that use the old [br] architecture, into the modern
age. generally it uses filesystem globbing (not `boxxy`) to get a splay of
nodes..




## philosophical underpinnings

the "philosophy" of the subject is exactly that as described in [#008]
"the plugin manifesto", which is to say generally composition over
subclassing, and avoiding "lot of magic" DSL's, with the overall goal
begin clarity and readability.




## case-study/tutorial :[#here.1]

(this coincides with real production code (contemporary with this
text) in [sn].)

this approach (not architecture) is new, so we spell it out: the
equivalent predecessor to this discovered and exposed the action
tree topology through a combination of [#co-030] "boxxy"-like
reflection, needing either to load business models unnecessarily or
to avoid doing so through the use of (awful) action "stubs". (these
older techniques are the defining characteristics of the [br]-era.)

this new technique attempts to discover the same topology through
generally simpler filesystem globbing and related specification.

the new way is meant to be more performant, require less code
and (most importantly) be easier to understand than its forebear.
its main cost in contrast to the [br]-era techniques it aims to
replace is this:

depending on how nuanced and varied your topology is (read: where
your action classes are with respect to what files are on the
filesystem), you will have to express that topology by adding
globs and paths all up front, here (as opposed to the obtuse
autoloading and stub-file based fragile magic we used to use).

in practice this requirement hasn't felt like a heavy cost so
far. and one plus side of this trade-off is that we don't have to
litter our non-participating participating business modules
(business modules were formerly called "silos") with `Actions`
consts with a value of nothing, for those model nodes that do
not have corresponding actions.

(side note, we still employ this technique for the equivalent
of what we used to call "promoted" actions :[#here.1].)


so:

*all* action "nodes" are under `Models_`. most action nodes are at
a "twice deep" location. for example, "models-/foo/actions/bar.rb"
holds the "bar" action of the "foo" model, and so on for many actions.

we call this "conventional" placement. but it is not the only way to
place actions, neither "physically" (i.e on the filesystem) nor
"logically" (i.e in your action tree).

those actions that have placement different from this conventional
placement will need to be found through additional globs added
explicitly. but first, for this conventional placement we use:

    models-/*/actions{,.rb}

which:

  - if we imagine the glob expression without the "{,.rb}" affixed
    to it, such a glob matches the four or so "actions" directories
    there. each such directory is assumed to have filesystem entries
    (files or directories) that represent *terminal* actions. this
    assumption is what we refer to when we say "conventional" placement.

    (we may expand this definition later to accomodate deeply
    recursive action trees somehow, but that is outside of our
    current scope and interest.)

  - appending the "{,.rb}" to the glob allows it to match also the
    any single files we have that define many action nodes.
    (currently there is one: "models-/tag/actions.rb"). :[#here.2] (see
    `File.fnmatch` near "FNM_EXTGLOB". it's fantastic that this works.)


we need to add explicitly:

    models-/criteria/actions

because:

  - although that node exists "logically", it doesn't exist
    "physically": we manage to fit all the code of the actions into
    the business node corefile, so its actions node wouldn't be
    found through filesystem globbing.

also (a bit hackishly) we need to add explicitly:

    models-/ping/actions

because:

  - although this node exists neither "physically" on the filesystem
    nor "logically" in our action tree ("ping" itself is an endpoint,
    it has no child actions), currently the "lingua franca" of the
    the remote facility is of sending an "actions module path", even
    when no corresponding real branch module exists at that node path.

    later when reflecting on the "ping" node, the remote performer
    will see that it does not in fact have child actions (:[#here.3])
    and it will procede appropriately. but for now, this is how we
    specify such nodes; nodes that are in effect terminal actions
    that are "sitting" in a spot where a model would normally go.
    subject to change.

finally, the order in which we add these globs here determines the
order they appear in the UI. (yes, within any given glob we're at
the mercy of how the filesystem orders the entries it produces
(lexically, probably). that's OK with us for now. at least the
ordering is consistent, unlike in [br]-era where we would get a
different ordering based on what nodes were already loaded.)





# :[#here.2]

this identifier tracks a common pattern whereby we want every action
(leaf node) in the tree to have repesentation on the filesystem in the
form of an isomorphically named file, whether or not that actual file
has any real content that it loaded. that is:

under this pattern, for files that would otherwise be "anemic" we might
stow the node away in a parent node; but we nonetheless want the file on
the filesystem because hitting the filesystem with one single glob query
is both efficient and has self-documenting properties.)





(EDIT everything below here)
#=== LEGACY:

# an introduction to a reactive model :[#!br-100]
  ( formerly: "the client tree model"


## foreward

this document is a transplant from the sunsetting [hl]. we have made NO
effort yet to modernize it for what it means in the context of [br].




## older foreward

we're putting this down here now as a point of reference without intending
to articulate fully the tree model in its complete scope and vision, in
all of the glory and splendor it radiates. but here's a summary:




## TL;DR:

an application tree is just what it sounds like. but as a matter of principle
we try to blur all kinds of lines in terms of what it means to be a root node.
vs. a branch node vs. a leaf node; so tht we can build trees of trees, and
so on.

if nothing else, look at fig.2 of [#ze-055], which is an ASCII drawing
of a client tree.



## ground already covered here

([#ze-055] ouroboros ..)



## ground is already covered in [fa]

the "face" subsystem (a sister library that we are in friendly competition
with) has covered a lot of the ground for us, in terms of essay writing.
there are tons of nifty ASCII graphics to go along with them to, it is
a riveting romp not to be missed.

so first we will present a list of the relevant articles, and then we may add
some comments at the end (one day this will be arranged appropriately enough
into a grand tree of its own):

• really the perfect illustration for the client tree model is in fig.2 of
  [#ze-055] "ouroboros and strange modules".

• [#bs-040] the matryoshka doll UI pattern is its own detailed spin on the
  tree model (all of which is relevant to here, because it has the exact
  some functional objective); and lays down some good general groundwork.


related articles:

• in [#bs-042] "this fun problem" we learn of way you can lock yourself
  out of extensibility with inheritance when implementing something like
  the tree model.

• in [#099.A] trending away from sub-clients, we whine about them there.

• [#ze-040] "what is the deal with expression agents" discovers the big
  problem with sub-clients (as they were implemented) and tries to fix them
  and then makes a big mess. (our [#!092] spares us no detail of the story
  of the great earthquake and fire that ensued.)
