---
title: "thoughts on expressing collection metadata"
date: "2018-08-09T06:28:38-04:00"
---
# thoughts on expressing collection metadata

## background/intro

this area of smell occurred to us when we transitioned from the
"synchronization" phase to the "tag lyfe" phase. it's the classic set-up
to justify dependency injection.

consider: synchronization cares about "natural key field name" but
"filter by" does not; and "filter by" cares about "tag lyfe field names"
but synchronization does not.




## <a name=2></a>whether to be jack of all trades

for example in the case of markdown tables, our solution for the problem of
needing the "tag lyfe field names" takes on two facets:

  - it is done "eagerly"
  - it is done in a "heuristic templating" style

our answer to the smells this introduced was the idea of "intention",
something that is not yet very formal.

basically, "intention" tries to munge "filter by" and "sync" with mostly
the same code, but gives you better, more directed (and more early warning)
error reporting geared towards your .. intention.




## <a name=3></a>heuristic templating

this relates to #open [#410.S]  (see, discussed there at length) which pertains to a
particular application of this theory that has yielded mis-behaviors.

but the "theory" of heruistic templating is that we look at the existing
formatting of the document to determine how we format new expression.

more at [#417.C], which segues into this (among other corollaries).




## <a name=D></a>example row synthesis

uh..

  - how many cels (characters) wide the cel is




## <a name=E></a>name change

um..

  - one thrust is to push the class up and rename it from "sync parameters"
    to "collection metadata". but this brings up the new smell of the
    dependency injection thrust introduced at the intro

what we would like is that "capabilities" "register" somehow, and that all
registered capabilities expose the property names they recognize for
collection metadata. (this indexing of capabilities would be done lazily,
a max of once per runtime.)

we would end up with such an index:

  - field names: (\*)
  - natural key field name: (sync)
  - tag lyfe field names: (filter by)
  - [ many other sync specific ]

but this is seen as overwrought for now.




## <a name='E.2'></a> provision: dictionary is the standard item

(explained in a context at [#408.E].)




## <a name=F></a> provision: the collision handler takes four arguments.

(this is up from the previous two it used to take before #history-A.1)
we made this change because we were gung-ho about etc but it seems it might
be redundant, because isn't a collision by definition when there is the same
natural key?




## <a name=G></a> provision: short circuit out of a merge operation

this provision holds that we short-circuit out of calling the merge callback
if the far "record" has no components other than the human key (because why
bother, right?).

there are, however, some caveates discussed in code.

.#coverpoint1.5




## <a name=H></a> provision: custom keyers

this provision holds that you can provide a function that "derives" a human
key per each item through arbitrary means. [#423.B] shows how a keyer can
work in conjunction with a mapper, in our "pipeline workflow".
(#coverpoint1.6)




## <a name=I.2></a> provision: the leftmost column in the markdown table is..

..by default the "human key" field.. we don't want to be fully
married to this but it's a cost-saving shortcut.





## <a name="I.3.1"></a> feature-ish: map for sync

(first read the description in the UI referenced with this tag then return
to here.) having not yet fully realized [#423.C] full, arbitray functional
pipelines to the extent that we would like, we for now have this more
hard-coded action for inspecting a producer stream after its various mappings,
filters etc are applied.





## <a name="I.3.2"></a> feature: far deny list

this "feature" is an outcropping of feature [#418.I.3.1] "map for sync"
(immediately above); that is it is a necessary byproduct of the wish to
inspect data in our pipeline and still meet the various requirements of
the consuming script. longer explanation at [#423.D].




## <a name="I.4"></a> feature: custom mapper oldschool

away at [#423.C] custom pipes, probably.




## <a name="I.5"></a> feature: static arguments to map makers

(this article is a stub)




## <a name=J></a> provision: there is a version integer for sync parameters.

this contrivance exists so there is a discrete, hard-coded assertion
somewhere about what constituency of names we can assume; both from
the defining side and the consuming side separately.

(probably we will get rid of this)




## <a name=K></a> provision: traversal params come from far stream (& synthesis)

for a synchronization:

  - you can't have a normal near stream without the traversal parameters
    (because you may have a custom keyer).
  - you can't have traversal parameters without a far stream. (EDIT: explain
    the thinking by importing a comment to here.)
  - you can't do the central syncing algorithm without the two streams.
  - finally, per the next point [#418.L], these streams gonna be in context
    managers..

so, in pseudocode:

    with open_far() as far:
        with open_near(far) as near:
            for output_line in sync(far, near):
                yield output_line

note the significant point here is that the order of the nesting is not
interchangeable. syncing depends on both far and near; near depends on far.
so the order must be:

  1. far
  1. near
  1. sync

in turn, the above is now considered #pattern [#418.Z.1].




## <a name=L></a> provision: the two streams should be in context managers
you can

.:[#418.L.2]: on failure you must sill result in an iterator




## <a name='M'></a> feature-family: multi-tablism

(this is a stub. it vaguely exists in one generator script but to get it
to work with syncing will be an undertaking.)





## <a name='Z.1'></a> pattern: nested context managers

(just tracking this for now)




## <a name='Z.2'></a> pattern: separate context managers from work

there should be a layer of abstraction that divides context-manager concerns
from the business work. if your work needs to access a resource that is
"emphemeral" (like an open filehandle, database connection etc), then perhaps
a context manager should be involved but it should not disrupt your code flow:

how this manifests typically is that we don't want our context manager class
to become a "god class" monolith that also holds a lot of busines work.

ideally such context manager classes will only define `__init__`,
`__enter__` and `__exit__` and pass off the business work to code that is
ignorant of the implementation details of context managers.




## <a name='Z.3'></a> pattern: this broad pattern: class as context manager

(..)




## <a name='Z.4'></a> pattern: the "Mad Parse" pattern.

this tracks a pattern where we make parsers that are:

  - small (at writing ~30-60 SLOC)
  - self-contained (no external dependendencies (modules))
  - implemented with a class
  - does this one weird trick where a "state" member variable points to a method

we track this pattern like so because despite all its excellent PROs above,
we might weirdly decide against all odds one day that it's a smell, that
there's some better alternative, etc.




## (document-meta)

  - #history-A.1: normal far stream became a thing
  - #born.
