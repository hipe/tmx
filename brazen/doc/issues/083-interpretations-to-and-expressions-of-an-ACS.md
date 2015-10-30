# interpretations to and expressions of an ACS [#083]



## context & scope

here we specify how both [#089] "compound" and "terminal" components of
an ACS typically handle input & output from and to various "modalities."
to be cheeky, we refer to input as "interpretation" and output as
"expression".




## "modalities"..

..is our catch-all term that refers broadly to "substrate" and
"encoding" when it comes to IO. for example, "JSON" is one modality.
there is a particular way that we "interpret from this modality, and a
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




## towards an interpretation API - unmarshaling

there exists a potentially limitless variety of ways that one component
for one ACS can be interpreted from the potentially limitless variety of
input "modalities". we will refer to the "thing" that does this
interpretation as an "interpreter", but we will offer no rigorous
specification for interpreters here.

it's worth comparing a [#089] "mutation session" to an interpreter - it
"feels like" the mutation session is acting as an interpretor for tenet
3 from there (thru which all compound components are presumably built in
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




### :#note-JSON-A

we do this by interating over the *whole* formal structure first, and
then complaining about any remaining unparsed items second. rather, we
*could* give the formal structure a hash-like inteface somehow, and then
iterate over each element of the parsed JSON structure using this map -
the different would be that for serialized structures that do not occupy
every formal component, there would be less iteration. however, because
we don't have that hash-like interface we are sticking with this.





### :#note-REFL-A

we want the node to be able to define its own (perhaps nil-ish) list of
each of the things. if one or more of the things is not defined in this
manner, we use the simple method index.

however, if one or both of these "name symbols" methods is defined,
then we effectively group the entries by category in this hard-coded
order.





### :#note-REFL-B

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
_
