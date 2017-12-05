# the model :[#013]

(see [#024] for concerns shared by actions & models)



## :#A.

a particular model node (that is, business model class) has an exposed
API IFF it has an 'actions' node. we take a nasty peak into the
filesystem here for now.




## :#B.

each given action node under the 'actions' node either does or does not
"promote" itself. a promoted action is one that is visible at one level
higher than it would be otherwise, were it not promoted. hence a promoted
action of a typical model class will appear in the first level of
actions that the application's emergent API has exposed, in-line
typically with other nodes representing each model node itself.

a "promotion" is like an alias, but rather than allowing for multiple
reference to the same referrant (which is what an alias does), the
promotion makes the node effectively cease to exist in its previous location
(from the perspective of the interface). it is a weird experiment.

why not just build the node in the "right" place in the first place, you
ask? well sometimes we like the verbs to go under the nouns when we are
structuring code, but not necessarily always when we are structuring
interfaces.

if you understood that much so far, then you're gonna love this part:
a model node all of whose actions are promoted does not itself need to
appear in the action scan (collection) for this level. in fact it should
not, because if all of its actions are promoted, it has no native-
appearing actions of its own to manage.

it is for this reason that the way we do action scans over a particular
model node may seem a bit odd:


### the odd thing about how we do action scans in a particular model node

for a model node that has an actions node, this will fall into exactly one
of these four categories:

1) the actions node has no actions, a state whose behavior is undefined.

2) the actions node consists entirely of nodes that do not promote themselves.

3) the actions node consists entirely of nodes that promote themselves.

4) the actions node has a mix of nodes that do and do not promote themselves.


for 2), during this scan the model node will only supply one entry
into the scan: itself. it has the duty to present and dispatch to its
children actions, but now is not the time for that.

for 3), the model will supply one entry for each such action, but no
additional entry for itself.

for 4), the model will supply one entry for each such action and one
entry for itself.

to summarize the above 4 points, the model node will promote itself IFF
it has a nonzero number of child nodes that did not promote themselves.




## :[#here.3]

the model is like the body. it craves sustenence and expression. the
actions of the model are like the hands of the body. they reach out to
touch things and bring them to the mouth to eat.

the properties of the actions are like the fingers of the hand.




## :API.A - unbound nodes whose consts have trailing underscores..

some model trees "in the wild" have nodes whose consts end in
underscores (always one at writing). of these trees, none of them intend
for these nodes to be public. that is, these nodes are not intended to be
part of the application's reactive model tree per se, but are just there
as a support model node.

note that a corollary of this is that you couldn't have a node as part
of your reactive tree that has such a name. this seems to be fine.

this in conjunction with boxxy's [#ca-030] inferred constants means
that such nodes do not even have to load (rather than loading it and
looking for an `Actions` const that is false-ish) when a node identifier
is being resolved.




## :API.B - now a "leaf node" can be at level-1 of the tree

some model trees "in the wild" now have actions at the top level in
their models tree. this is in opposition to the "pure" model created
15 months ago, where the first level had to be model (branch) nodes.
that is, if the tree itself is "level-1", and all of its immediate
children are at level-1, then it use to be that level-1 was exclusively
supposed to be model nodes proper. now this constraint no longer exists.

this initially happened by the necessity of simplification - when we
experimentally resolved silo names with the same promotion-aware logic
we use for unbound selection, would have had to put the silo daemon in
the action class that was promoted, which was ick. avoiding that
potential graph, we just promote the action but rather have it in the top
level of the tree. if ever there needs to be mre than one action it can
branch back down again.

however, silo selection must *not* be subject to promotionality -
otherwise (covered [tm]) we can end up with inacessible silos for those
branch nodes for which every child is promoted (covered).




## :[#here.B]

copy-pasted from 'action'. models that do have any child actions may get
'infected' by the child's name function function. but models that don't
wont.




## :[#here.C]

do not set error count in the contructor. error count is set only when
it is guaranteed to be written to during an edit session. this way, an
error count of zero will always mean the entity is valid (provided we
follow our own rules). setting the error count to zero here could result
in us mistakenly thinking that an entity is valid.




## ("model ivars" #open :[#018]) :[#here.D]

we say "actual property" with the exact sense of "actual"
from [#fi-002.2] formal attributes vs. actual attributes.

using ivars to hold actual properties where the ivar's name is unadorned
will create problems and is not sustainable in the current
implementation:

imagine that we can enforce some naming rules for e.g property names may not
start with underscores, and all of our mechanical ivars must. this is
annoying because we don't want to limit the client from using meaningful
leading underscores in her property names: she may have some business
reasons to want to do this. also it's just ugly to have to read and
write code with lots of leading underscores in ivar names. it is a
limitation we should avoid.

so let's accept as a given that the property namespace is and always
will be wide-open.

if we are to continue to want to appreciate the convenience of having
actual properties stored in ivars, then we would have to go to the other
extreme: somehow avoid using ivars entirely for anything mechanical.

the workaround for this for now is to use `dereference` (and the
separate but related `action_property_value`) for reading actual
properties.




## the model property ordering rationale :[#018]

when defining the "properties" (formal arguments) of a typical method,
we are familiar with the ordering rationale of "volatility order":
generally we place those formal parameters whose actual parameters are
more likely to be different from call to call towards the beginning.
this optimizes for refactorability, as large classes become smaller and
less volatile arguments become ivars or are given C-style defaults, etc.

when defining the properties for a model we *may* tend towards a
different ording rationale depending on how certain end clients behave..
