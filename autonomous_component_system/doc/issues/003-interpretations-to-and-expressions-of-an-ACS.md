# interpretations to and expressions of an ACS [#003]



## context & scope

here we specify how both [#002] "compound" and "terminal" components of
an ACS typically handle input & output from and to various "modalities."
to be cheeky, we refer to input as "interpretation" and output as
"expression". there is also the closely related idea of "intent"
explored below at [#here.D].




## "modalities"..

..is our catch-all term that refers broadly to "substrate" and
"encoding" when it comes to IO. for example, "JSON" is one modality.
there is a particular way that we "interpret from" this modality, and a
particular way we "express to" it as well.

the ways in which [#019] "intent" is distinct from "modality" might not
be valuable, and is certain not defined concretely.





## what is a semi-formal definition for an ACS?

just so we agree on terms in this document,

  • here we conceive of an ACS as a directed graph, a tree,

      * with every child node having a name that is
        unique in the context of its parent

      * the root node has no name

      * furthermore we'll conceive of the children of these
        nodes as being ordered.

      * nodes that have children have nothing but children, and nodes
        that have no children we've called a variety of things (e.g "field",
        "atom") but we'll call "leaf" for now.





## the N "axiomatic operations" of an ACS (i.e "compoundesque" node)

(this is placed here for narrative continuity with the above and below;
that is, it is more specific than the above but more general than the
below, and relates to both sections. the concept is assembled at [#022].)




## towards an interpretation API - unmarshaling :[#here.1]

there exists a potentially limitless variety of ways that one component
for one ACS can be interpreted from the potentially limitless variety of
input "modalities". we will refer to the "thing" that does this
interpretation as an "interpreter", but we will offer no rigorous
specification for interpreters here.

it's worth comparing a [#002] "mutation session" to an interpreter - it
"feels like" the mutation session is acting as an interpreter for #Tenet3
from there (thru which all compound components are presumably built in
a normal world). (however, internally it is the particular component class
itself that actually constructs a mutable component, before passing it off
to a mutation session which interprets the input.)







## "method index"

### why we cache the method index :[#here.B]


the default assumption is (reasonably) that the compound is not going to
create new instance methods on-they-fly on its singleton class in order
to express new component associations or formal operations (because
although this has been designed from the ground up to support dynamic
such formals, this is not the way to do it).

as such, we *do* cache the "constituency" of those "nodes" defined by
instance methods (because per the previous paragraph, these instance
methods should be coming from "static" classes which should not be
changing during runtime).

(we do *not*, however, cache the formal structures that are produced by
these methods -- to do so would be in direct conflict with one of the
primary design objectives of the [ac], near [#002]#DT3 dynamicism.)




### :"the moment at which we cache the entries" :[#here.C]

when the method index is in its beginning state, use the below hand-written
map-reduce to produce each next "entry"; all the while memo'ing each entry
produced for the one stream. if such a stream ever reaches its end, this
moves the index out of this beginning state: for subsequent requests we used
the cached array of entries.

the reason we don't traverse and then cache every entry outright is that we
don't want to have to traverse every item if we don't have to (for example
if we are seeking only one item as opposed to expressing all items).

however, if ever we do reach the end, then if we don't cache all this
work it's a lost opportunity to save ourselves the effort the next time
we might need it.

the benefit of this is revealed by #coverage-1, which shows the cache
being used.

the worst case cost to this is if we were were repeatedly request a node
near the the end but never reach the end.




## the "intent" node

### "intention method", "intent" :[#here.D]

the elegant wonder of the ACS near "interpret component" is the idea
that we could use the same method (validation) whether we are
unserializing data (e.g from disk or wire) or normalizing data from a
user. all such input should be validated anyway, so it would be nice to
have to define at most one method per model to these ends.

this theory seems to serve us well generally, but there are potential
issues with it. to express these issues we use the idea of "intent":



#### understanding "intent"

the broad approach is based on the premise that structures that express
our UI and API will be similar or same-ish ("isomorphic") to the structures
involved in serialization/unserialization. we like to believe that this
premise stands for the 80%-plus of simplest cases, but it can be a big
leap, and it doesn't always hold water (indeed, it can be a "leaky
abstraction"):

there may be cases where the model designer wants the internal structure
that represents the mutable data (the "model" in the classical sense)
to differ from what is effectively the interface structure used to
express the UI or API. ([mt]'s adapters are an example.)

(this thread is continued at [#019])




#### case-study: on JSON interpretation (as a seqway into something..) :[#here.E]

at one time the JSON interpretation node effected a "unit of work"
pattern whereby in two separate passes it would 1) "line up" JSON
payload nodes with something like component models, and then 2) try to
build each component from each payload node recursively, in a manner
that was somewhat "atomic."

while that "felt good" in theory, in implementation it was seen to be built
on false premises that stem from a violation of what we now call our
"design tenets", specifically #DT2 and #DT3:

  • per #DT2 we must use the same underlying logic assets for unserialization
    that we use for normalization (thru API/UI interface). in implementation
    of this principle, for all non-primitive components we use the component
    model's "construction method" (near #Tenet6) and we use the same construction
    method regardless of intent (unserialization or UI)..

  • (..and towards autonomy #DT1 it must be that all such constructed
    components are valid by the time they leave this construction
    method and are resulted from it. (otherwise the construction method
    can result in false-ish.))

  • per #DT3, components express their associations thru reflection on the
    *component*, not the component model (for orthogonal & dynamic models).
    we cannot use the model to reflect on the component, we can only use
    the component itself.

because we need the component instance before we can reflect on the
component associations of that selfsame component, and because we must
use the same sort of construction method for unserialization that could
be used for the other intent (and the call to the construction method
must result in a valid component if it results in one at all),
experimentally we attempt this trick (next section):




### the "super-signature" of construction methods :[#here.F]

in an ideal utopia of "true autonomy" the component model needs nothing
more than the argument scanner and a handler to construct itself from
arguments. the simple "node identifiers" of [sn] are exemplary of such
a use case. (indeed the ACS grew out of this.)

however, component models of non-trivial complexity may need access to
resources and information beyond just what is available in the argument
scanner in order to parse build a valid, normal component from that
scanner.

to accomodate this we specify one "super-signature" for construction
methods:

  • if the block "slot" of the method is to be used by this component
    model, it *must* be used for an event handler.

  • the method *must* accept at least one (non-block) parameter: this first
    parameter is a *mixed* argument that somehow expresses access to some
    sort of input stream.

      * for non-compound models this has never not been an argument stream.

        + when the argument stream is received as empty (visible thru peeking)
          this typically means that a new empty component is desired,
          typically for use in the interface "intent"

      * for compound models, this is under exploration and is
        being tracked with :[#here.F.2] "compounds"

  • if this construction method takes more than one argument, the *last*
    argument will be the ACS that is building this as a component
    (the "parent"). this is a violation of the design tenet of autonomy
    so keep this in mind when you design this sort of dependency into your
    system. #DT1

  • if the constructor takes more than 2 arguments, the *second to last*
    argument will be the association structure. (but keep in mind that per
    [#006.A.1] "most" components won't need to know their own name.)

  • the constructor cannot take more than 3 arguments.

for sanity of implementation and future-proofing, the constructor must
not define defaults for any parameters.




### on JSON expression :[#here.G]

(this section is to precede the following "note"-style sections.)

originally we held the perspective of "the more the merrier" when it
came to data dumps in JSON - we wanted the extra structural validation
that would come with having lots of references to association names,
even if their values were `nil`. we do not hold this perspective any
longer.

if we were to hold onto this "sparse" strategy, we would end up with
very big trees with essentially nothing in them when our ACS's are
starting out.

furthermore this makes tests fragile as we add components.




### about `nil` :[#here.H]

the "common" way we deal with `nil` for both expression and interpretation
is that we treat it as equivalent to the value not being set. this is so
regardless of if the component model is compond or "atomic" or other, etc.

the extent to which we do this for interpretation may have unexpected
results - if we ever (and we should not ever) use interpretation to mutate
an existing ACS, effectively skipping `nil` assigments would also skip
overwriting whatever value is currently in that slot. but we hope than
we never use interpretation in this way.

as for expression, handling `nil` the same as not present is convenient
- the ACS can set its "slot" to `nil` as needed and check for whether this
is set thru checking its truthiness (without needing to use the non-pretty
`instance_variable_defined?`). however, we have never encountered a case
where we want to differentiate whether a value was not set as opposed to
being set to `nil` over serialization.




### about false :[#here.I]

when it comes to `false`, however, (in contrast to handling `nil`
above), we always simply treat it as-is.




### (truprim-note)

truish-primitives..




### (heavy-note)

a "heavy atomic" is a component that has a dedicated class to manage it,
but when it comes to serialization, it only needs one primitive value to
be stored. when it gets unserialized it is crucial that this be
translated back to such a dedicated object, and not the primitive as-is.

the component itself has the autonomy to decide whether it is a heavy
atomic or a compound component (somehow), and can change this thru its
lifetime.




### :#trueish-note :[#here.J]

we're using this to mark places where the component must be true-ish, for
example because it is expected to be controller-like ..




### extensibility - creating custom meta-components for comp assocs :#X1

(this is demonstrated in the spec that references this identifier.)




### :#infer-desc :[#here.L]

track the multiple places where we do this similar thing
_
