# pluralton persistence in git config documents :[#024]

## CAVEAT:

this document is being re-assembled piecemeal in steps from a large rewrite
so that it's not an insane spike of a largely disassociated wall of text.

depending on at what point you're reading this in its lifeline, it may or
may not make much of a coherent narrative.

although effort has been made to introduce dependended-upon sections as
we introduce sections that depend on them, the narrative won't truly be
smoth until the reassembly is complete. (EDIT: remove this whole section
when etc.)




## synopsis #[#here.a]

sparing no detail and leaving no stone unturned, we develop, explicate
and present an algorithm for persisting entities with "pluralton" (i.e
polymorphic one-to-many) associations in a manner that attempts to preserve
existing comments and arbitrary formatting in the human-readable store.




## table of contents #[#here.a]

  - synopsis, table of contents, prerequisites, intro, scope [#here.a]&[#here.A]
  - design factors #[#here.b]
  - provisions 1 thru N [#here.C]
  - critical theory for approaching the algorithm: comparison [#here.D]
  - M, N and C [#here.E]
  - "clusters" [#here.F]
  - necessary background: platform implementation of hash tables (dictionaries) [#here.G]
  - how can we determine "practical equivalence"? [#here.H]
  - initial indexing of the components and the document [#here.J]




## prerequisites/suggested pre-reading #[#here.a]

  - the subject started as (and continues to be at writing) in service of
    only one client. [#cu-011] "internal architecture" given an overview
    of that client that is pertinent to our work here. (currently the
    referenced document falls short of this goal EDIT.)

  - the subject amounts to complex a marshaling (serializing) algorithm.
    for whatever reason it's much easier to understand the accompanying
    unmarshaling (unserializing) first, and then come back to here. so
    [#cu-010.fig-1] serves as a good introduction to the landscape here.




## introduction #[#here.a]

this is complex because we made it that way. deletions and insertions
into the list of items that make up a [#here.A.2] "pluralton" group are
conceived of as an
"edit" that could perhaps involve a re-ordering as well as these two
other operations.

the work involved in persisting (and then unserializing) pluralton
groups will have its own particular challenges; but also this
effort falls under the general rubric of our kinky persistence fixation
which is something like this:

if we were able simply to discard all of a survey document's
nodes and rewrite them with the nodes we have in memory, it would be
easy and we could go home.

but we have given ourselves the daunting and perhaps false requirement
that the document can contain non-data informational phenomenon like
formatting and comments that do not "isomorph" with our entity but that
nonethess have value to us that we want to persist. in fact it's not a
false requirement, it's a choice we feel strongly about.

(note: we'll let [#br-047] be the official "proprietor" of the concept
of "entity" but here when we say "entity" it's sufficient to say we mean
an unordered set of name-value pairs that represents some business .. thing.)



### what is "pluralton"? :[#here.A.2]

we're making up "pluralton" as the opposite of "singleton" because there
is no one-word term for it in data modeling. (there's a "cardinality" of
"one-to-many" but that's it.)

this should probably move up into a modeling concern ([fi] probably)
and so we'll hold off on giving it exposition here..

(EDIT)

the summary is it's like a glob, but the items in this list can be
of a variety of "types"..

more specifically, in the context of indexing:




## scope #[#here.a]

we should bear in mind that [#br-009] "git config" is just one of many
possible persistence substrates. although our choice of this substrate
is justified in the next section, we should neither take this substrate
for granted nor allow its particularies to reverberate into our broader
architecture.

like perhaps all of the data structures in our universe, surveys are
tree-like; and they can be represented as recursive structures that
terminate with simple primitives (integers, strings, booleans etc).

it should be imagined that something like JSON should offer a fair
substitute if there was a reason to target that.




## design factor: structural requirements & constrains on both sides #[#here.b]

although this was developed for a single client and a single one of its
(albeit polyadic) [#here.A.2] pluralton associations; a side-benefit of
attempting this robustly for our initial use case is that it might have
wings for use cases beyond just this one; i.e. for document-backed
entities more generally (as we will delineate and formalize below).

furthermore, by developing a robust model for how pluralton components
can be persisted in the target document, the work will overarch the work
involved in persisting plain old singleton components, and may allow us
to mostly supercede its theory with this more widely applicable theory.

to understand the essential challenge of this effort, we should
consider the underlying structural characteristics of (on the
one hand) our storage substrate and (on the other) our entity.

first, our storage subtrate: for our purpose we can characterize
[#br-008] "git config" documents as something like a two-dimensional
array. the [#here.b.3] next section will review the pertinent structural
details of this, our chosen substrate.

from the "root" of the document it "feels like" an associative array
(or if you prefer, ordered dictionary a.k.a ordered hash) where the
keys of the hash are like the names of the sections, however that's
not a good characterization because unlike dictionaries whose keys
are unique and one-to-many per item, there is no such constraint on
the section name/sub-section name tuple of the sections in a document

(i.e you can repeat a section name (or a section/sub-section
combination) in such a document and it still parses, and is
furthermore still "valid").

as for one level down in our documents (i.e within a section), again
it "feels like" an associative array but that's deceptive because you
can weirdly use the same name (left hand side) of an assigment over and
over again on multiple assignment lines and it's still "valid" (and valid).

(we've seen this applied meaningfully (if somewhat awkwardly) to express
the addition of individual items to a list in the config files of
{ gitolite | gitosis (EDIT) }, but we don't like it.)

note that as explored [#here.b.3] below, this depth does not recurse: this
is the end of the line. the assignment values themselves must intrinsically
be primitives. (in some ways that were discussed previously and other ways
that were not, you could try to hack your way around this but we want to
avoid this.)

now as for our entity: as we speak we come up with three categorizations
of structure. at the highest level, we'll refer to those entities that are
"documenty"; that is, they can be isomorphed into a "document" in the
manner we are describing. at the next level down we'll conceive of entities
that are "sectiony"; that is, they can be isomorphed losslessy into the
document sections as we are describing. finally we'll conceive of some
components (note we don't say "entities") that are "primitive"; that is,
they can be represented as a name-value pair where the value is something
like an integer, string, boolean, etc.

the point of this all is to say (somewhat tautologically) that what we
are explicating here covers only the persistence of those entities
that are "documenty" (and their sub-compoents on down recursively); and
not entities generally. (athough, we have hinted at dubious avenues that
could be explored if we needed solutions in this limited substrate for more
complex structures.)

all of *that* is to say that this is not a recursive algorithm. "documenty"
entities are made up of "sectiony" entities and those are made up of
primitive components. we have just these three levels to worry about
and our descent won't recurse. however:

while our current goal is to solve for persisting "documenty" entities
(and their sub-components on down recursively to the base case), this
serves as both an end it itself and also as a means for perhaps an even
more general solution for entities of greater complexity than those that
are "documenty".




## design factor: review of the storage substrate itself (properties & limitations) #[#here.b.3]

to review the pertinent details of a specification (our reflection of
which lives at EDIT), "git config" documents consist of zero
or more lines where each line is either a whitespace/comment line, a
section (or subsection) line, or an assignment line, and that's it.
that is, every line will fall into one of these three categories.

furthermore every assignment line must be associated with (i.e come
after) a section line; which is to say your first assignment line may
not occur before your first section line. (when this happens it is
expressed as an error by the remote facility; we don't have to worry
about it here.)

grammatically there is no nesting of sub-sub-sections and so on.
in fact, the name "sub-section" is perhaps misleading. it is simply
that a section line can have an optional second descriptive string.

however, because the sub-section string can be almost any string,
if you wanted to hack something terrible you could exploit a flat
but ever-growing namespace with subsection names like "1.1.1.1.3"
and so on to represent trees of arbitrary depth (not recommended).

also you could refer to sections by name in the values of your
assignments, opening up the possibility of modeling an arbitrarily deep
tree structure, say, with sections whose names are sequential integers,
and then you associate branch nodes with other branch nodes by
referring to the integer somehow in assignment values. yikes!

again that is not recommended, it's just that we mention it to say
that this document structure with very few rules can be exploited to
represent complex structures.




## design factor: identity is not composition #[#here.b]

one factor that makes persisting pluralton components more complicated
than persisting singletons is that when it comes to pluralton components,
identity is not composition. the report may contain multiple instances
of the same function with the same curried args. although we may think
of this as "the same" function, it is being called in two different
places and can certainly have two different side-effects or results in
those various places.

to fortify the point, these various "same"-looking calls may have different
comments around them in the config file, or even different use of
whitespace in how they are represented in the file. two (or more)
different functions in the config file may have the same composition but
it does not mean they have the same identity.

because of what is perhaps a false requirement that we want our
persistence files to be human-readable *and* editable, we have to keep
in mind this difference between identity and composition as we re-write
the file.

(we will revisit (and perhaps discard) the notion of identity #here2.)




## provision 1 (tentative) - components are one-to-one with sections #[#here.C.1]

every section in the document will have a one-to-one correspondence
with a component in the entity, *sort of*. (subsequent provisions will
put a finer point on this.) the uptake is that you can have no section
in the document that does not correspond to a formal *association* of
the entity's model. likewise the components of the entity will each
correspond to sections in the document *sort of* (as described below).

(a corollary of this is that when we encounter a section that we cannot
resolve to an association, we will generally fail in place. but we may
explore that in more depth somewhere elsewhere below.)




## provision 2 (experimental) - the names of sections for components in pluralton groups #[#here.C.2]

building off provision 1 (which holds that every component will have
a corresponding section and conversely that every section corresponds
to a component), the corresponding section for every component of a
pluralton group will have a section name (not sub-section name) that is
the name of the association (inflected appropriately so it is a valid
section name). conversely every section that has a name (not sub-section
name) corresponding to a pluralton association will correspond to a
component that is a member of that pluralton group.




## provision 3 (experimental) - the sub-section names for pluralton components #[#here.C.3]

sub-section names in the context of persisting pluralton components are
given a purpose that is a special provision of pluralton components only,
one which does not apply to "sectiony" but non-pluralton (i.e singleton)
components: we use the sub-section name to hold a "human" inflected name
of the *model* of the component. this is VERY experimental, but for now
satisifes a need..




## critical theory for approaching the algorithm: comparison :[#here.D]

for our purposes, the similarity that one "entity/section" can have to
another (when they are (for the purposes of this discussion) "similar")
will take the form of one of three discrete, mutually exclusive
classifications (so, non-nesting categories). that is to say, two
entity/sections can be similar to each other in one of four ways:
either in one of the three categories of similary, or not at all.



### "surface identical"

one is "surface identical" (which, caveat: we don't expect to use this
in a practical way but it's important conceptually) which means that
every line of the section (i.e the surface representation) is identical
byte-for-byte (including formatting, whitespace, comments, etc) to that
of the section being compared to. the reason we may not ever utilize this
category of similarity in practice is because this form of equivalence
requires the comparison of "surface bytes" (e.g whitespace, formatting,
comments) and to have those you have to have sections, not just entities;
and as it works out we maybe don't ever compare one *section* to another,
but rather only ever entities against sections..



### "practical match" - introduction :[#here.D.3]

another form of equivalence (and one we'll be relying on most heavily)
is "practical match". two entities are a "practical match" if they are
instances of of the same model (entity class) and their pertinent data
members are a practical match too. (yes, that part of the definition
is recursive, and we'll terminate it next.)

their pertinent data members are a practical match if they have the
same constituency (i.e set of names, insensitive to order (a case that
will always be true for two instances of the same class)) and (perhaps
recursively) that each corresponding value is a practical match too.

(we will hold off on defining "pertinent" for a while.)

(it's tempting to use the term "composition" somewhere in here but we're
holding off on broadening our network of jargon.)

the fact that we have defined this concept recursively may seem variously
overcomplicated, a liability, or even erroneous; however indulge first the
following provision, and then these several analogies as justification:

we can simplify the imagining of this in our minds with the provision that
a "practical match" is only applied between two "sectiony entities" (which
only ever have primitive components formally), so perhaps we won't need to
recurse anyway. but note that this concept of "practical match" could
recurse and it won't be a problem:

to understand this distinction: imagine that we accept as axiomatic that
hotel suites are made of up rooms and rooms are made up of furniture and
walls and that we can sub-divide furniture and walls into smaller and
smaller components, and so on until we get down to the level of a
"small thing" that we no longer care to subdivide (exactly the idea
(and etymology) of the word "atom").

we can then apply this recursive definition of equivalency by saying that
two hotel suites are equivalent IFF they have rooms that are equivalent,
and two rooms are equivalent IFF each of their corresponding walls/furniture
are equivalent, etc etc on down to the design on the fabric of the drapes,
the placement of the electrical outlets, etc.

the point is this is a recursive definition of equivalence: that two things
are equivalent if they are made up entirely of sub-components, and you can
line up the each sub-component with a counterpart on the other side
("destructively", i.e you "line up" any same component with more than one
other component) and apply this same definition of equivalence to those two
sub-components, etc on downards until you reach some kind of base case,
where perhaps you are comparing two "primitive" datapoints (for example,
comparing colors, or heights).

contrast on the other hand comparing two "pockets" of "change" (currency).
first, accept as axiomatic that any two nickels ($US 0.05) and two pennies
($US 0.01) are practically equvialent (and so on) for the sake of this
discussion. straining the metaphor somewhat, our conception of "equivalency"
is concerned with *constituency* (or maybe call it composition here), and
not simply with dollar amount. meaning: we consider two pockets of change
as equivalent IFF you can line up (destructively) one coin from one pocket
with an equivalent coin from the other pocket (for some definition of
coin equivalency).

note that here, the coin is seen as an indivisible "unit" so we do not
recurse any lower than that the level of comparing two coins.

the difference between hotel suites and pockets of coins is that with the
coins we don't need to recurse, however note that the recursive definition
of equivalence still works for the coins case.




### "practical match" and identity

repeating what may be at this point a familiar refrain, under the world
of "pluraltons" two entities can be practical matches but have distinct
identities.

so for example the first and third items in the list might look the
same; but that is not to say they are the same component. this
phenomenon certainly occurs in the physical world: the ball bearings
of a car's axle (or whatever) may be for practical purposes
identical to each other; but they nonetheless have individual
identity (and if one was missing things could go terribly wrong).
maybe the red blood cels of our body are similarly "fungible" with
each other but still have their own individual identity.

(side note one: the fact that in this model two things may have
discrete "identity" but be for all purposes interchangeable,
it challenges the utility of our notion of identity. note for one thing
that the "identical twins" analogy loses relevance in this discussion.
(they for certain have individual identity and are not interchangeable.)
the bottom line here is that we may want to sidestep the concept
of identity entirely, and rely instead only on our model of categories
of similarity alone :#here2.)

(side note two: generally when we say "constituency" here we mean roughly
the name-value pairs of an "entity" as an *unordered* set; so two entities
have the same constituency if they have the same components (by association
name) with the same values (against their respective counterparts); but the
idea of an "order" of these components is some combination of irrelevant or
non-appicable i.e meaningless.)



### "can be changed component"

this is a sketchy category of comparison. the idea here is that if
when held up against the entity expressed by a section, the entity
in hand is not a practical match (because the constituency of *its*
components differs in some way; e.g by the set of all association
names, or by the values of one or more of the components (note we
didn't say "identity" because we're assuming here that these components
are primitives)); yet nonetheless we "can" "re-use" this section
(with modification) to represent the entity in hand.

by design (but not necessarily through corollary) we'll say that
a section qualifies as one such match for a component if A it's of
the same component association and B is of the same model class.

later we'll introduce the practical utility of this kind of comparison;
but the TL;DR: of why we have it is so that we retain any whitespace,
formatting, and (possibly not pertinent) commments in a section that
would otherwise be discarded (along with its comments).

probably we'll want to generate notices in such cases, to warn the
user that the data content has changed within a section and so the
comments (if any) should be reviewed to see if they still make sense.




## M, N and C :[#here.E]

  - let "M" be the list of *all* the [#here.b.3] sections of the old
    document (in their order). (mnemonic: "M comes before N")

  - let "N" be the imaginary list of *all* the sections of the document
    that will exist (in their order) when our edit (i.e insertions,
    deletions, re-ordering) is complete. (mnemonic: "New document")

(side note: because it is an uninteresting problem, we are going to ignore
the leading zero or more lines (necessarily comment-and-or-whitepace,
per the git config document grammar) that exist before the first section
line in this discussion, in the knowledge that they will always come out the
other side as unchanged and in their same position as offset from the
beginning of the document. this provision alongside M and N mean that
our algorithm built by decomposing M and N will account for every line
of the entire document (both before and after the edit).)

thinking out loud: reaching N means we have succeeded are are finished.

  - let "participating sections" be those sections in M that are part
    of the pluraton group under operation. this is simply all sections
    in M that have the relevant section (not sub-section) name as determined
    by the relevant name of the association (which is a pluralton). (hint:
    this corresponds to the name of the ivar in the entity that holds the
    array of components in this pluralton group. it is probably a plural
    noun.)

so far, getting M is easy (it's every section in the document at first)
and determining the list-subset M' of participating sections is also easy
(it's trivial to reduce by section name). now,

  - let "C" be the full, ordered *list* of components in the relevant
    pluraton group in the entity which reflects the accurate, up-to-date
    state we want to persist into the document to get from M to N.

solving for N given M and C is the crux of our algorithm.

(note: there may be other pluralton components within the entity that
will undergo this same process so that they can be persisted; but we
are going to keep things simple for now and limit our focus to one
relevant pluralton association for the duration of this algorithm :#here1.)




## "clusters" :[#here.F]

recall that some sections in [#here.E] M will be "participating", and others
will not. it is a design objective that we accomodate any possible
arrangement of interspersions of participating and non-participating
sections. as such,

  - let a "cluster" be an uninterrupted "run" of *zero* or more
    participating sections in M.

  - when M does not begin (or end) with a participating section,
    we will model a cluster of length 0 there.

  - clusters (for M) must otherwise be of length 1 or more.

  - no cluster may abut another cluster.

given all of the above, for any M there is exactly 1 "clusterization".
for example, a run of only non-participating sections ("n") is
"clusterized" into a zero length cluster, a run of non-participating
sections, and then capped by a zero length cluster:

    nnn    =>    CNC

(only for the purposes of the examples in this section will we use
"C" to stand for "cluster" instead of what it normally stands for
("components"), and "N" to stand for "non-participating run" instead
of what it normally stands for ("new document", maybe).)

when M is the empty list ("[]"), it becomes just one zero-length cluster:

    []     =>    C

if M consists only of participating sections ("p"):

    ppp    =>    C

other examples:

    ppnn   =>   CNC

    nnpp   =>   CNC

    npnp   =>   CNCNC

the form that all "clusterizations" take can be generalized as:

    C (NC)*

or just as soon:

    (CN)* C

that is, always one cluster, followed by zero or more pairs
consisiting of a run of non-participating sections and a cluster.

(or the description of the other pattern).

we won't proscribe which of these two representations we will
conceive of the pattern as, but this is an irrelevant detail.




## clusters synthesized :[#here.f.2]

(EDIT: maybe away this whole section. cluster-level operations aren't
really a thing, are they?)

we will define the operations necesary to get from M to N (or we won't,
see the following sections) in terms of the "operations" necessary to do
on each cluster (one (possibly "compound" operation per cluster) such that
every cluster will either be:

  - deleted,
  - left unchanged or
  - modified

firstly (and as somewhat of an aside), building off of only what we
have presented thus far, this "cluster-centric" approach for producing
an N from M and C will *not* be able to produce all possible N that could
exist that solve for this. this is because our approach "locks" the
non-participating sections to where the are *relative to each other*,
and no where did we specify this as a requirement. well now, we are:

we take this approach of "locking" the non-participating sections'
positions with respect to each other (in part) because per #here1 there
might be other pluralton groups represented in those sections and we
must not corrupt them by re-ordering them.

so to restate what we have established so far, it will be trivial
to derive a single, deterministic "clusterization" "L" for any M.
(we can do so deterministically with an algorithm that while not
presented anywhere here would be straightforward.)

the trick, then, is to solve exactly *one* operation for each of
the *one* or more clusters in L..




## necessary background: platform implementation of hash tables (dictionaries) :[#here.G]

we have to delve into how the platform (and probably most general
implementations as well, in spirit) implement hash tables. it's really
not implementiation: it's more the API for using hash tables. because so
much of this happens "under the radar" for probably 9999 out of 10000
cases, it's probably a fair bet that day-to-day most users of hash tables
don't think about (and perhaps many don't know) about the following.

first of all, the basics of hash codes:

  - the instance that you want to use as a *key* must produce a
    "hash code" (integer) in response to the method called `hash`..

  - because this method is built into the classes of most of the things
    that programmers typically use as hash keys (symbols, maybe strings,
    maybe integers, even modules) it can frequently go unnoticed. but
    this method is not defined for every object there is:
    try `{}[ ::BasicObject.new ] = nil`.

  - this hash code integer must be *the same number* for different
    such instances that are to be considered "the same". so, for example
    if you evaluate `"foo".hash` in `irb`, you will see it produce a
    (probably long) integer. run this same thing again (in the same
    session) and you will see the same long integer. but note that
    these were two different string instances that each produced the
    same hash code. (you can confirm this by running `"foo".object_id`
    repeatedly, you will see different object ID's.)

  - if the above were not the case, then you would not be able to
    retrieve an item that you stored under the key `"foo"` with the
    key `"foo"`!

  - how this number is achieved for such instances is uninteresting to
    us, but we think this is called the "hashing algorithm". more on this
    later.

  - note (as an aside) that if you end the `irb` session and start it
    up again and evaluate `"foo".hash`, you will very likely see a different
    number than you did before. probably to discourage developers from making
    silly assumptions about the permanance of hash codes, the hashing
    algorithm is probably seeded with some kind of randomness per instance.
    but this is a detail (and also a black box) to us.

now, consider the possibility that two *different* (i.e "different")
objects that you want to use as keys end up making the *same* hash code.
(googling "ruby hash collision" brought us to an explanation that is vaguely
near ours, so far.)

  - for these cases, the `eql?` method is used to determine if the
    two instances (the one out the "outside" and the one one the "inside")
    are to be treated as the equivalent (both in cases of lookup, and
    assignment (i.e `[]` and `[]=`).

we do not understand why if you use the same object as a key for storage
as you do for retrieval, `eql?` is not called; however if you use two
different objects (one for storage, another for retrieval) that both
produce the same hash code, `eql?` is called.

the significance of all of this will become clear in the next section.




## initial indexing of the components and the document :[#here.J]

a next big step in this pipeline is that between the components in the
pluralton group and the sections in the existing document, we find those
that associate with each other through practical equivalence. this section
illustrates how we go about that in detail.

we have demonstrated above how we may distill the "practical identity" of
an item from either of these sides down to a plain old sequential integer,
by using a hash as a cache to keep track of each new "profile" that is seen
and assign it each next positive integer (starting at 1).

because it feels like it makes more sense when we get near the end,

  - we index the document first, and the components second. #theme-2

so,



### indexing the document

  - for each entity implied by each section in each cluster in L,
    "touch" its profile and add to this index the "locator" of this
    section in this cluster in the document.

note that multiple sections may each have the same practical identity,
and in such cases there will only be one "profile" but it will have
multiple "locators".

for the duration of the following case explanation, we will use a notation
convention where each next letter of the alphabet is used to represent
each next signature, and each time there is another occurrence of the
signature we say the "prime" of it:

    A  A' | B  C  C'  C''  D | E  F

this is a representation of a single "pluralton group" with 9 items
(i.e. components, i.e entities).  there's 6 signatures, 3 clusters.
some of the signatures are exhibited multiple times. in more detail:

  - the pipe ("|") indicates boundaries between clusters

  - "A'" is practically equivalent to "A", "C''" is practically
    equivalent to "C'" and "C", and so on.

  - in this example it just so happens that practically equivalent sections
    fall next to each other (and always in the same cluster), but there is
    no reason to see this as a trend, pattern or rule.

  - (take care not to confuse the letters we use here with the special
     meanings we have assigned to certain letters in the broader context
     of the algorithm. they are unrelated.)

remember above we said that we would index the document (L) first and
components (C) second. so:



### indexing the components

crucially, during this explanation we are using the same notation
conventions *and namespace* as above when we indexed the document.

so let's look at our components in this case:

    D Q C A A' E F

the first component has a practical identity "D" that *is* the same
practical identity of "D" from the above sub-section about indexing
the document. the same for "C", "A", "A'" and so on. but note:

  - "Q" is a random new profile that we hadn't seen already in L. as such,
    we can consider this an "add" of a new component to the document,
    rather than a possible repurposing and/or repositioning of an
    existing entity.

    adding components (as opposed to moving them) is a less difficult
    problem and so it won't receive attention for a while. but we'll
    pick back up with adding components along #theme-3.

  - in other possible cases, there could be multiple components like Q.
    one important edge case is where *all* components are like Q (that is,
    none of them are in the existing document by practical equivalence).
    another important edge case is when C is the empty list.

  - the "heaviest" design objective of this algorithm comes from this
    provision: the ordering of these components of C can be totally
    arbitrary and new when compared to the ordering we had in L (as it
    pertains to the items that are in both (in terms of practical
    equivalency)). note that in the components, C (the item) comes before
    A, and D comes at the front (whereas in the document D comes after C
    and C comes after A).

  - note too that not all items that are in the document are in the list
    of components. (this is the complement to the point above about items
    like Q, which are items that exist in the components but that don't
    exist (by practical equivalence) in the document.)

but this indexing is only the beginning..




## towards synthesis: how can we determine "practical equivalence"? :[#here.H]

recall provision 1 which provides that every section must express
an entity. to attempt to derive an entity from a section can in
practice fail, because in the set of all imaginable section "bodies"
is typically not the same as the set of all valid "bodies" for most
models (but ultimately this is up to the model). anyway, such a case
classifies as an input validation error and should be expressed
as such should fail (softly but unrecoverably) out of this algorithm;
but it is otherwise uninteresting to us here.

so for our purpose imagine that we somehow "have" an entity for every
section in [#here.f.2] L (or every relevant section in [#here.E] M,
whichever you prefer to see it as). mind you we have just now done the
opposite of what we are doing generally. what we are doing generally is
"persisting" (i.e marshaling (serializing)); but what we have just
done (getting an entity from a section) is unmarshaling (unserializing).
this is because at the crux of this algorithm is comparing the entities
in C against the existing would-be entities implied by M, and we do this
through comparing entities (not sections).

recall too the idea of a [#here.D.3] "practical match". we think we present
here a conception of "practical matching" of entities to each other that
is as simple as possible while still being as complicated as necessary:

  - we use a derivative of the entity as a hash key in a hash
    intended to hold the "constituency signature" (or do we call it
    "profile"?) of all the entities we have yet encountered that we
    want to compare.

huh? this algorithm requires that every participating entity expose a
"practical match comparator" to be used as a hash key. why do we use
such a dedicated exposure (derivative) rather than just use the entity
itself as the hash key?

  - two arbitrary business objects with the same composition don't
    out-of-the-box produce the same hash code. (try:

        class Foo ; end ; Foo.new.hash ; Foo.new.hash

    if you do the last 2 statements on separate lines, you'll see this.)

  - we don't want to have to override `hash` or `eql?` on our business
    classes themselves because we want to make it clear that this is a
    task-specific sense of equality we are defining. recall from above
    that we introduced *three* different categories of equality. what we
    are discussing here is but one of them and it doesn't "deserve" to
    hijack the entire `hash` and/or `eql?` method just for this one
    domain-specific concern. :[#here.H.2] (see associated #code-example.)

  - and if we *did* want to override the `hash` method of our business
    classes, it would lead us down a similar rabbit hole to where we
    are now anyway.

so, if we want to determine which of a set of entities (say from list C)
have practical equivalents in the list of entities in L, the least bonkers
(but still kind of bonkers) way we have come up with to do so is:

  - the entity will expose the "essence" of itself (for the purpose
    of finding practical matches) as `_practical_match_comparator_`.

to get really into the weeds for a moment, it's convenient to implement
this "practical match comparator" by having it be a recursive structure
(ideally not too complicated) consisting only of arrays and primitives
as necessary. run `[:foo, [0, "bar"]].hash` two times and see that the
same hash code is produced even though the structures were two entirely
separate objects (well, two separate arrays, two separate strings).

if we use array structures like this to stand as the comparator for any
given entity, then if we don't ever need to override `hash` and `eql?`
anywhere, instead letting the recursive array structure just stand for
itself, as it were. in more detail, the advantages of this approach are:

  - overriding `hash` and `eql?` require an "imperative" style (writing
    logic in code) as opposed to the "declarative" style above (writing
    structures in code). generally the "declarative" style is seen as
    having advantages over the "imperative" style [citation needed].

  - overriding `hash` and `eql?` require explanation and a link back
    to this god awful treatise.

  - overriding `hash` and `eql?` incur a dependency on the platform
    API that (albeit subjectively) "feels" more fragile that what we
    are doing above.

anyway, now that we have an object with these two requisite properties:

  - the object that emobodies the "essence" of the entity's constituency
    for the purpose of finding practical matches

  - the object can be used as a key in platform hash tables (and has the
    behavior we want against the platform's hash API).

now, with an implementation suggested by the below pseudocode we can
maintain a single ("long running") hash to derive a plain old integer
identifier for every practical match "profile" we are dealing with.

    practical_match_identifier_via_comparator = -> do
      counter = 0
      ::Hash.new { |h, k| h[ k ] = ( counter += 1 ) }
    end.call

the above forms a closure around `counter` and (in effect) assigns a
new integer to every incoming key (er, comparator) it hasn't seen before.

in this way (finally) we can have a plain old integer (starting at 1,
with new integers allocated sequentially) that represents the "essence"
(we keep avoding the term "identity") of any participating entity for the
purposes of finding other entities that match it (practically). whew!




## the algorithm

partition the existing config file's "report" section into a
grouping we impose here: the section is composed of nodes. each
node either is or is not an assignment. and of those, the
assignment either is or is not a line representing a function call.

partition the section into groups of nodes ("spans") based around
these function calls. each span has one "main node" (the function
call) and the others in the span are children nodes (anything other
than function calls).

each such marshaled function call is parsed. on parse failure, we want
to discard the function call * perhaps * by turning that line into a
comment and placing this whole span e.g at the end or in some otherwise
undefined place within the section.



### defining terms near "function"

identity is not composition. the report may contain multiple instances
of the same function with the same curried args. although we may think
of this as "the same" function, it is being called in two different
places and can certainly have two different side-effects or results in
those various places.

to fortify the point, these various "same"-looking calls may have different
comments around them in the config file, or even different use of
whitespace in how they are represented in the file. two (or more)
different functions in the config file may have the same composition but
it does not mean they have the same identity.

because of what is perhaps a false requirement that we want our
persistence files to be human-readable *and* editable, we have to keep
in mind this difference between identity and composition as we re-write
the file.




## note-25

each span (consisting of a function and N number of non-function nodes)
is partitioned into a list of other spans whose function has that same
composition.

for each function in memory that we want to write back to persistence,
we first consult this hashtable to see if a node already exists for a
function with the same composition. if so we remove that node from the
pool and use it to write back to persistence (with all comments etc
intact).

(if not we create new nodes) (any nodes that are left in the pool at the
end of this process we do something crazy with.)




## document-meta

  - EDIT: get rid of every metion of "survey"

  - EDIT: get rid of "note 25" and its referrent

  - #history-A.1: begin mostly a full rewrite for
    pluralton-in-git-config persistence

  - #pending-rename: incubating, waiting for a name.
