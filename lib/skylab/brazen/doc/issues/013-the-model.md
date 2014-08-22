# the model :[#013]



## :#one.

a particular model node (that is, business model class) has an exposed
API iff it has an 'actions' node.  we take a nasty peak into the
filesystem here for now.


## :#two.

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

it is for this reason that the way we action scans over a particular
model node may seem a bit odd:


### the odd thing about how we do action scans in a particular model node

for a model node that has an actions node, this will fall into exactly one
of these four categories:

1) the actions node has no actions, a state whose behavior is undefined.

2) the actions node consists entirely of nodes that do not promote themselves.

3) the actions node consists entirely of nodes that promote themselves.

4) the actions node has a mix of nodes that do and do not promote themselves.


for 2), during "this" scan the model node will only supply one entry
into the scan: itself. it is its own duty to present and dispatch its
actions below that, but now is not the time for that.

for 3), the model will supply one entry for each such action, but no
additional entry for itself.

for 4), the model will supply one entry for each such action and one
entry for itself.

to summarize the above 4 points, the model node will promote itself iff
it has a nonzero number of child nodes that did not promote themselves.


## :#three.

the model is like the body. it craves sustenence and expression. the
actions of the model are like the hands of the body. they reach out to
touch things and bring them to the mouth to eat.

the properties of the actions are like the fingers of the hand.
