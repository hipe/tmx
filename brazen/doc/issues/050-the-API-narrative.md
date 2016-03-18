# the API narrative :[#050]

## introduction

"API" as a specialized concept and specific facility has existed in
"this" universe for years. the subject file is at the time of this
writing almost two years old; the first occurrence of "API" per se (with
these [lowercase ick!] letters) appears more than a year before that.

although the subject file has gone thru enough structural rewrites to make
it unrecognizable when held up againt its first commit, its intent and
high-level behavior have remained largely the same.



## brief history and cultural context

the subject node was imported from [tm]. other notable attempts at
reusable API facilities have occured variously [ sunsetted face API lib ] and then
[#!hl-017] off of that.

the birthday of the latter code-node is a week or two after that of the
subject code-node, so they share DNA:

in the latter code node itself, the discerning eye will see lots of
isomorphicism and early conceptual ancestors of most of the main components
we use today: there is one long running lightweight "daemon"-ish and then
for each request a dedicated "invocation" instance has a short-ish lifespan.
[#fi-033] "iambics" were quite formalized by then too, and used then as
they are now as the lingua franca for API actions.

in fact, we re-purposed descriptions from the now sunsetted [#!hl-017]
to here as supplemental [#079] the API API components narrative.




## #note-015 :[#051]

an expression agent as a singleton (that is, effectively global) instance is
certainly *not* something we will provide support for broadly. it exists
here because we want to render events in "black and white" for testing
and for turning events into exceptions; and it seems extraneous to fire
up an entirely new expression agent for these tasks each time, and also
it may be inconvenient or impossible to provide invocation-specific
arguments to the would-be expression agent, when all we want is to get a
human-readable string out of an event (again, for testing or exceptions)
from some strange place.

however in the universe some expression agents will be built with the
action as an argument so that they can render modality-specific surface
representations of arguments for example. because of this,
expresssion-agent-as-singleton is not something that should be adopted
broadly.

in fact, the code and this whole section may one day be removed.
