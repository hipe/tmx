# interpretations to and expressions of an ACS [#083]



## context & scope

here we specify how both [#089] "compound" and "terminal" components of
an ACS typically handle input & output from and to various "modalities."
to be cheeky, we refer to input as "interpretation" and output as
"expression". there is also the closely related idea of "intent"
explored below at #INTERP-B.




## "modalities"..

..is our catch-all term that refers broadly to "substrate" and
"encoding" when it comes to IO. for example, "JSON" is one modality.
there is a particular way that we "interpret from" this modality, and a
particular way we "express to" it as well.




## what is a semi-formal definition for an ACS?

just so we agree on terms in this document,

  • here we conceive of an ACS as a directed graph, a tree,

      * with every child node having a name that is
        unique in the context of its parent

      * and that name (let's just say for now) is a name that
        isomorphs cleanly with the spec at [#013]:API.A,

      * ergo the root node has no name.

      * furthermore we'll conceive of the children of these
        nodes as being ordered.

      * nodes that have children have nothing but children, and nodes
        that have no children we've called a variety of things (e.g "field",
        "atom") but we'll call "leaf" for now.




## :ASSUMPTION-A ..

.. is the assumption that we are not yet long-running. we use this tag
to track areas that could be improved if we become long-running.




## towards an interpretation API - unmarshaling

there exists a potentially limitless variety of ways that one component
for one ACS can be interpreted from the potentially limitless variety of
input "modalities". we will refer to the "thing" that does this
interpretation as an "interpreter", but we will offer no rigorous
specification for interpreters here.

it's worth comparing a [#089] "mutation session" to an interpreter - it
"feels like" the mutation session is acting as an interpreter for #t3
from there (thru which all compound components are presumably built in
a normal world). (however, internally it is the particular component class
itself that actually constructs a mutable component, before passing it off
to a mutation session which interprets the input.)




## the modality API of "reactive tree"

### what is a hybrid? :#note-RT-A

the "unbound"/"bound" dichotomy is one that tries to leverage the
"classical model" in which taxonomic, model and action nodes are
represented variously by modules, classes and (again) classes
respectively. this adaptation of an ACS into a reactive tree is
decidedly not the classical model. as such, we attempt to reduce noise
in our implementation by using the same object to act as an unbound and
bound node. we refer to such objects as "hybrids" here.




### :#note-RT-B

we don't want it




### :REFL-A

that component association structures are built anew on-the-fly whenever
they are requested is an experiment. let's track where this potentially
feels wasteful in case we change our minds.

(that we create it anew is because of #dt3 dynamicism. that we want not
to waste it is because of #dt4 conservatism.)




### :#note-REFL-B

we want the node to be able to define its own (perhaps nil-ish) list of
each of the things. if one or more of the things is not defined in this
manner, we use the simple method index.

however, if one or both of these "name symbols" methods is defined,
then we effectively group the entries by category in this hard-coded
order.





### :#note-REFL-C

when the method index is in its beginning state, use the below hand-written
map-reduce to produce each next "entry"; all the while memo'ing each entry
produced for the one stream. if such a stream ever reaches its end, this
moves the index out of this beginning state: for subsequent requests we used
the cached array of entries.
the rationale behind this is that we don't want to index every node if we
don't have to (for example if we are seeking only one thing as opposed to
all things). (although the way we may do this now may not need this
stream anyway.)

the benefit of this is revealed by #coverage-1, which shows the cache
being used.

the worst case cost to this is if we were were repeatedly request a node
near the the end but never reach the end.




### notes about "univeral build" & "upbinding" :#note-INTERP-A

honoring tenets t1 and t6 [#089], "interpret component" is for now the
de-facto standard way we build a new empty component for example for
edit sessions, unserializing, building reactive trees, etc.

now consider all this:

when parent receives events from child (we call them "signals" when
they are intercepted like this), it needs to know which child sent the
signal. a direct approach for this would be for the child to receive
its name function in the eyes of its parents through some sort of API
callback method near construction time. (indeed we went pretty far with
this approach before revisiting its design.)

but the experiment of ACS is meant to encourage decoupled design. for
the child to need to know what its name is in the eyes of the parent
is a bit of a challenge to this principle. that is, we would like for
the ("child") component not to know that it is even a child per se.
(indeed, part of autonomy is gaining independence from one's parents!)

in fact we avoid the use of the term "child" in our code here for this
reason. we would like for the component's behavior to be effected
similarly whether it is some sort of child or some sort of top. ideally,
the concept of "being a child" would be meaningless to the component.

the [#ca-001] selective listener pattern is a perfect fit for this: the
component is constructed with an event handler, and need merely emit
events when appropriate. (typically, when its constituent business data
changes).

if the component is constructed by something like a parent, the parent
can construct (usually wrap) the handler specially to add information
about the "child"'s name when the signature of the emission matches the
approrpriate channels.




### "intention method", "intent" - :INTERP-B

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

these different classifications of concern referred to above we call
"intents" - we consider [un]serialization one "intent", and API/UI
another. (munging API and UI into one intent is itself a broad leap
the ramifications which we won't explore here, but is the theory behind
[br] in general.) at present, we have come up with no "intents" other than
"serialization" and "interface".

so, there are at least two issues that express themselves within our
broad approach. they are not showstoppers, but for now they present the
need for necessary handling. each of these issues express themselves
through some "special handling accomodation". they are:



#### special handing accomodation 1: expression of `intent`

although we like our models to be relevant across intents, we have found
it inhibits our expressive power to have this to be a given always.
experimentally, you can now specify an `intent` in your componenent
*association*. the syntax is something like:

    intent { serialization | interface }

A) to use this "meta-component" is in violation of #t2 the tenet of
DRY-ness across all intents; so it should be used sparingly let the
whole ACS experiment will be proven a failure! when not expressed
explicitly, the compnent association being defined is assumed to be
relevant for all intents (as it should be).

B) it is arguably a violation of #t1 "component autonomy" to have the
parent component deciding how it wants to the child (with regards to its
intent); but by designing the formal expression this way rather than
leaving it up to the child to express (somehow) allows for code that
"feels" still #dt3 dynamic while trying to be #dt4 conservative under
whatever the active intent is.



#### case-study: :#JSON-interpretation (as a segway into something...)

at one time the JSON interpretation node effected a "unit of work"
pattern whereby in two separate passes it would 1) "line up" JSON
payload nodes with something like component models, and then 2) try to
build each component from each payload node recursively, in a manner
that was somewhat "atomic."

while that "felt good" in theory, in implementation it was seen to be built
on false premises that stem from a violation of what we now call our
"design tenets", specifically #dt2 and #dt3:

  • per #dt2 we must use the same underlying logic assets for unserialization
    that we use for normalization (thru API/UI interface). in implementation
    of this principle, for all non-primitive components we use the component
    model's "construction method" (near #t6) and we use the same construction
    method regardless of intent (unserialization or UI)..

  • (..and towards autonomy #dt1 it must be that all such constructed
    components are valid by the time they leave this construction
    method and are resulted from it. (otherwise the construction method
    can result in false-ish.))

  • per #dt3, components express their associations thru reflection on the
    *component*, not the component model (for orthogonal & dynamic models).
    we cannot use the model to reflect on the component, we can only use
    the component itself.

because we need the component instance before we can reflect on the
component associations of that selfsame component, and because we must
use the same sort of construction method for unserialization that could
be used for the other intent (and the call to the construction method
must result in a valid component if it results in one at all),
experimentally we attempt this trick (next section):



#### special handling accomodation 2: the compound construction method

the experimentation of this is the subject of this commit, and will not
be commented on until it has incubated a bit. it is tracked with
#INTERP-D.




### the "super-signature" of construction methods :#INTERP-C

in an ideal utopia of "true autonomy" the component model needs nothing
more than the argument stream and a handler to construct itself from
arguments. the simple "node identifiers" of [sn] are exemplary of such
a use case. (indeed the ACS grew out of this.)

however, component models of non-trivial complexity may need access to
resources and information beyond just what is available in the argument
stream in order to parse build a valid, normal component from that
stream.

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
        being tracked with INTERP-D.

  • if this construction method takes more than one argument, the *last*
    argument will be the ACS that is building this as a component
    (the "parent"). this is a violation of the design tenet of autonomy
    so keep this in mind when you design this sort of dependency into your
    system. #dt1

  • if the constructor takes more than 2 arguments, the *second to last*
    argument will be the association structure. (but keep in mind that per
    #INTERP-A "most" components won't need to know their own name.)

  • the constructor cannot take more than 3 arguments.

for sanity of implementation and future-proofing, the constructor must
not define defaults for any parameters.




### :#INTERP-accept-component-change

all about this important method:

mainly, implement the handling of the signal by storing the
new component value. (this is guaranteed at this point.)

secondarily, result in a *proc* that results in a structure that
can be used to propagate this mutation signal outward to cilents.

(see code)

epilogue:

now: we are an ACS that has mutated. in some cases we have stored
a first-ever component value into one of our component "slots",
and in other cases we have swapped-in a new component value
over an old one. these two cases correspond (in reverse) to the
two different forms of "soft event" we make from the same DSL.

as a crucial part of the typical ACS's specified behavior, it
must notify any listening clients that it has changed. however,
it is outside our own scope of concern here to know whether the
ACS has any listening clients and if so, how to signal this
mutation to them. that is why we result in a proc that builds a
specialized informational structure. it is up to the client (our
client) to decide whether to build and if so what to do with this
built structure.





### :note-JSON-expression

(this section is to precede the INOUT notes next)

originally we held the perspective of "the more the merrier" when it
came to data dumps in JSON - we wanted the extra structural validation
that would come with having lots of references to association names,
even if their values were `nil`. we do not hold this perspective any
longer.

if we were to hold onto this "sparse" strategy, we would end up with
very big trees with essentially nothing in them when our ACS's are
starting out.

furthermore this makes tests fragile as we add components.




### :INOUT-A

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




### :INOUT-B

when it comes to `false`, however, (in contrast to handling `nil`
above), we always simply treat it as-is.




### :INOUT-C

truish-primitives..




### :INOUT-D

a "heavy atomic" is a component that has a dedicated class to manage it,
but when it comes to serialization, it only needs one primitive value to
be stored. when it gets unserialized it is crucial that this be
translated back to such a dedicated object, and not the primitive as-is.

the compoent itself has the autonomy to decide whether it is a heavy
atomic or a compound component (somehow), and can change this thru its
lifetime.




### "why no blocks?" :#note-OPER-A

for now, we don't pass the oes block here because (child) components
have a special block created for them that lets them send messages to
the parent without knowing whether or not they have a parent. this
special block is created at construction time and is an instance
variable. to reduce the strain on the ACS class, we don't require that
it create an attr-reader for this proc, just so that we can read this
proc and pass it back to the selfsame component. rather, we expec that
the component manage its own eventing in this manner, by calling its own
ivar with the special block.

however, this treatment of this situation is *very* default and is not
expected to hold up for all uses.




### :#issue-1

the way we autovivify here should be the way we do there (see).
_
