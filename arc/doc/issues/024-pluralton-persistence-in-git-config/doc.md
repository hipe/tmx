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

(EDIT remove this section to close #open [#008.E])




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
  - why do we go through the extra trouble? [#here.i]
  - initial indexing of the components and the document [#here.J]
  - why the crazy diff thing [#here.K]
  - the crazy diff thing [#here.L]
  - the beginning of the final clusterization [#here.M]
  - finishing the final clusterization with capsules [#here.N]
  - EDIT sponge expanding and contracting, units of work [#here.O]
  - appendix: indexing a definition of "pluralton"-participating parameters :[#here.p]
  - appendix 2: too many kinds of offsets :[#here.q]





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




## provision 4 (experimental) - isomorphic ordering #[#here.C.4]

  - it is an essential requirement of pluralton groups that we represent
    faithfully the order of their items. how we proscribe this here is
    experimental, but the end is not. so:

  - the sections that represent these items do not have to occur
    contiguously in the document, however,

  - the order in which these sections occur with respect to each
    other corresponds to the order of the items in the pluralton group.

an alternative being considered is to represent an offset (or ordinal)
as an integer somewhere in the representation. advantages to this approach:

  - when items are re-ordered, this will be less "taxing" on the document
    from the perspective of a VCS (i.e. the change to the document will
    require less information to represent).

  - re-orderings would be easier to implement, probably.

however we opt against it for now for these reasons:

  - it "feels" more intuitive to exploit the in-document ordering:
    documents (as well as memory storage in computing generally)
    have an inherent one-dimensionality which isomorphs with order
    in an obvious way, and not to exploit this would seem to be
    contrary to the principle of least surprise (which is to say,
    we want to do it the way we want to do it because it's probably
    what is expected).

  - to put the ordinal (offset) in the sub-section name would feel
    like a hack

  - to "take up" an assignment for such a purpose would cut into
    a cordoned-off namespace for business attribute names.

  - to have such an assignment attribute start with an underscore
    in the avoidance of above (think couchdb) feels like a hack and
    looks like an eyesore.




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
sub-components, etc on downwards until you reach some kind of base case,
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

we're gonna use these letters (and later, some others) to stand for
bespoke sets (or lists) of things in this document. NOTE these special
letters will *not* be used *anywhere* outside this document.

  - let list "M" be the list of *all* the [#here.b.3] sections of the old
    document (in their order). (mnemonic: "M comes before N")

  - let list "N" be the imaginary list of *all* the sections of the document
    that will exist (in their order) when our edit (i.e insertions,
    deletions, re-ordering) is complete. (mnemonic: "New document")

(side note: because it is an uninteresting problem, we are going to ignore
the leading zero or more lines (necessarily comment-and-or-whitepace,
per the git config document grammar) that exist before the first section
line in this discussion, in the knowledge that they will always come out the
other side as unchanged and in their same position as offset from the
beginning of the document. this provision alongside list M and list N mean that
our algorithm built by decomposing list M and list N will account for every line
of the entire document (both before and after the edit).)

thinking out loud: reaching list N means we have succeeded are are finished.

  - let "participating sections" be those sections in list M that are part
    of the pluraton group under operation. this is simply all sections
    in list M that have the relevant section (not sub-section) name as determined
    by the relevant name of the association (which is a pluralton). (hint:
    this corresponds to the name of the ivar in the entity that holds the
    array of components in this pluralton group. it is probably a plural
    noun.)

so far, getting list M is easy (it's every section in the document at first)
and determining the list-subset M' of participating sections is also easy
(it's trivial to reduce by section name). now,

  - let list "C" be the full, ordered *list* of components in the relevant
    pluraton group in the entity which reflects the accurate, up-to-date
    state we want to persist into the document to get from list M to list N.

solving for list N given list M and list C is the crux of our algorithm.

(note: there may be other pluralton components within the entity that
will undergo this same process so that they can be persisted; but we
are going to keep things simple for now and limit our focus to one
relevant pluralton association for the duration of this algorithm :#here1.)




## "clusters" :[#here.F]

recall that some sections in [#here.E] list M will be "participating", and others
will not. it is a design objective that we accomodate any possible
arrangement of interspersions of participating and non-participating
sections. as such,

  - let a "cluster" be an uninterrupted "run" of *zero* or more
    participating sections in list M.

  - when list M does not begin (or end) with a participating section,
    we will model a cluster of length 0 there.

  - clusters (for list M) must otherwise be of length 1 or more.

  - no cluster may abut another cluster.

given all of the above, for any item in list M there is exactly 1 "clusterization".
for example, a run of only non-participating sections ("n") is
"clusterized" into a zero length cluster, a run of non-participating
sections, and then capped by a zero length cluster:

    nnn    =>    CNC

(only for the purposes of the examples in this section will we use
"C" to stand for "cluster" instead of what it normally stands for
("components"), and "N" to stand for "non-participating run" instead
of what it normally stands for ("new document", maybe).)

when list M is the empty list ("[]"), it becomes just one zero-length cluster:

    []     =>    C

if list M consists only of participating sections ("p"):

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

we will define the operations necesary to get from list M to list N (or we won't,
see the following sections) in terms of the "operations" necessary to do
on each cluster (one (possibly "compound" operation per cluster) such that
every cluster will either be:

  - deleted,
  - left unchanged or
  - modified

firstly (and as somewhat of an aside), building off of only what we
have presented thus far, this "cluster-centric" approach for producing
an list N from list M and C will *not* be able to produce all possible items in N that could
exist that solve for this. this is because our approach "locks" the
non-participating sections to where the are *relative to each other*,
and no where did we specify this as a requirement. well now, we are:

we take this approach of "locking" the non-participating sections'
positions with respect to each other (in part) because per #here1 there
might be other pluralton groups represented in those sections and we
must not corrupt them by re-ordering them.

so to restate what we have established so far, it will be trivial
to derive a single, deterministic "clusterization" list "L" for any item in list M.
(we can do so deterministically with an algorithm that while not
presented anywhere here would be straightforward.)

the trick, then, is to solve exactly *one* operation for each of
the *one* or more clusters in list L..




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
    us now, but we think this is called the "hashing algorithm". we'll
    revisit this later.

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

  - for each entity implied by each section in each cluster in list L,
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

remember above we said that we would index the document (list L) first and
components (list C) second. so:



### indexing the components

crucially, during this explanation we are using the same notation
conventions *and namespace* as above when we indexed the document.

so let's look at our components in this case:

    D Q C A A' E F

the first component has a practical identity "D" that *is* the same
practical identity of "D" from the above sub-section about indexing
the document. the same for "C", "A", "A'" and so on. but note:

  - "Q" is a random new profile that we hadn't seen already in list L. as such,
    we can consider this an "add" of a new component to the document,
    rather than a possible repurposing and/or repositioning of an
    existing entity.

    adding components (as opposed to moving them) is a less difficult
    problem and so it won't receive attention for a while. but we'll
    mention adding components ([#here.N] set A) throughout.

  - in other possible cases, there could be multiple components like Q.
    one important edge case is where *all* components are like Q (that is,
    none of them are in the existing document by practical equivalence).
    another important edge case is when list C is the empty list.

  - the "heaviest" design objective of this algorithm comes from this
    provision: the ordering of these components of list C can be totally
    arbitrary and new when compared to the ordering we had in list L (as it
    pertains to the items that are in both (in terms of practical
    equivalency)). note that in the components, C (the item) comes before
    A, and D comes at the front (whereas in the document D comes after C
    and C comes after A).

  - note too that not all items that are in the document are in the list
    of components. (this is the complement to the point above about items
    like Q, which is of that category of the items that exist in the
    components but that don't exist (by practical equivalence) in the
    document.)

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
section in [#here.f.2] list L (or every relevant section in [#here.E] list M,
whichever you prefer to see it as). mind you we have just now done the
opposite of what we are doing generally. what we are doing generally is
"persisting" (i.e marshaling (serializing)); but what we have just
done (getting an entity from a section) is unmarshaling (unserializing).
this is because at the crux of this algorithm is comparing the entities
in list C against the existing would-be entities implied by list M, and we do this
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
have practical equivalents in the list of entities in list L, the least bonkers
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




## towards synthesis: why do we go through the following extra trouble? [#here.i]

recall we have list L (which is 1 or more clusters of participating sections,
each cluster being separated by runs of one or more non-participating
sections), and we want to get to list N, which is the list of sections that
persists list C (the list of components we want to persist).

the general challenge here (and it was a true challenge) is that we
want to reduce as much as possible unnecessary "strain" on the document:
we want to change it as is necessary (for some given means of quantifying
change).

this is in its way an exercise in "aesthetic" refinement; that is,
we could just say "forget this" and flip the table and just say
"take the first (or last (or middle)) cluster and put all of the
items from list C
into this cluster and delete all the other clusters", but if we do,
then

  - for one thing, we lose comments in list L if we just blindly replace
    them with the items in list C without looking for matches

  - for another thing, if we were to do this then the document would give
    the appearance of way more change happening than it is.

  - for a third thing, if the user had some reason for arranging the
    "clusterization" (list L) as it was, then we would like to retain that
    arrangement as much as we can while still accomodating the edit.

so now that we have the justification for the following out of the way:




## why the crazy diff thing :[#here.K]

building off of the "indexing" we've accomplished in the above
sections, this is a visual statement of our fundamental problem:

    (existing document)   (components)        (new document)

     A                        D                     ?
     A'                       Q                     ..
    ---                       C                    ---
     B           +            A         =           ?
     C                        A'                    ..
     C'                       E
     C''                      F
     D
    ---                                            ---
     E                                              ?
     F                                              ..


one thing we haven't stated yet explicitly is that we need to preserve
the "---" jumps both in terms of their constituency and their order.
what each of them represents is a run of one or more non-participating
sections and it is an absolute requirement that we preserve them in (again)
both constituency and order :#theme-1.

to appreciate this problem with a focus on one aspect, we'll re-present the
above but with an emphasis on whether and how much each item is "moving":


    (existing document)   (components)        (new document)

     A  -------+      +---->  D                     ?
     A' -----+  \    /                              ?
    ---       \  \  /   X-->  Q                    ---
     B  --> X  \  \/                                ?
     C  ------- \  \------->  C                     ?
     C' --> X    \  \                               ?
     C''--> X  /  \  +----->  A                     ?
     D  ------+    +------->  A'                    ?
    ---                                            ---
     E  ------------------->  E                     ?
     F  ------------------->  F                     ?


if this looks like a mess, it is supposed to.

having drawn arrows showing where each item moves to relative to the
other items (and having come up with a notation demonstrating both
removes and adds), it doesn't magically solve the problem of where
to put the cluster "breaks" (the "---") that we need to carry over
into the new document.

when developing this algorithm, we actually got as far as considering
taking into account the *slope* of each such conceptual arrow to determine
which of the items to move. we realized then that what we in fact wanted
was a plain old diff algorithm, and at that point we decided we should
use an existing `diff` tool instead of writing one ourselves.

so the centralest mechanic of this whole circus becomes this: conceptually
we flatten the tree of sections so that they in their order can be compared
to the list of components, and then get a "patch" (list of line-level
instructions) from this and use that to inform our output document.
(it's actually a bit simpler than that as we will see.)

the value in this approach is that we have an external, known facility
that manages determining a diff for us, rather than cobbling something
together feebly ourselves. the payback, though, is that we have to
re-assemble a clusterization in a way that hews close to the original
document structurally (to some extent possible), while using this patch
to inform the order of its leaves.




## the crazy diff thing, at the center of it all :[#here.L]

here we present in a manner a bit more like pseudocode the "lining up"
that we did above with the drawing of the [#here.K] arrows. then we take
this a step further by showing how we can leverage `diff` to make the
decisions for us to decide which items are to be considered as "moving"
vs. which are "stationary". so:

we do something else when we index the components, beyond just determining
their practical identity (integer): we see if such an item (by practical
identity) exists in the document that can be "lined up" "destructively"
with this one. we represent such a "lining up" as something we call an
"associated locators", because we'll be associating one "locator" (think
plain old offset) to a component with one "locator" (think 2-integer offset
tuple) for a section in the document.

(further on in this document we will refer to the above phenomenon as
simply an "association".)

so for each next component that we "index", we'll "line it up" with one
from the document if we can, and it gets a new "associated locators"
association. the items below that have associations with items in the
document have an integer by them, and these integers are sequential
starting from zero. the integer is the offset of the "association locators"
structure in a list of every such structure ever made for this effort.

    D  0
    Q
    C  1
    A  2
    A' 3
    E  4
    F  5

so to restate somewhat, the above items with offsets next to them are
items that have an associated counterpart section in the document.

the number is not an offset into the document in any sense. it is only
an offset uniquely identifying the association. when looked at from this
perspective of a pluralton group, the numbers will always start at zero
and increase by 1. this is by design:

we index the document first and the components second (#theme-2), so we
discover associations in an order that accords with the order of the
components (but note there can be :[#here.L.3] "holes" where there's a "new" component
that is not associated with any existing section in the document).

the above items with the same base letter but a different prime (here
"A" and "A'") are practically equivalent to each other, but note that
they get their own association to their own section in the document,
because of the important fact that associations are "destructive".

in groups of practically equivalent items such as this, note that there
is no correlation between the number of such items on the component side
and the number of equivalent sections on the document side. that is, it's
possible to "run out" of available practically equivalent sections, or to
have some practically equivalent sections "left over" after items are
paired up.

note that Q is (in this case) the only component without an association,
because it's the only component that doesn't have a counterpart in the
document.

so now go back and look at these same offsets of associations when
grafted over list L:

     A   2
     A'  3
    ---
     B
     C   1
     C'
     C''
     D   0
    ---
     E   4
     F   5

of this visualization, note:

  - the offsets don't appear to accord to the order of the sections
    in the document. this is intentional, because this case is
    designed to illustrate a significant re-ordering.

  - note too that this is a more condensed representation of what we
    illustrated above with all the arrows pointing every which way;
    which is to say we haven't actually solved anything new yet.

without explaining why we do this until we get there, we're going to
do this: reduce these two illustrations to only the numbers in them,
and imagine they are in these two files:

    existing-document.txt        components.txt
             2                         0
             3                         1
             1                         2
             0                         3
             4                         4
             5                         5

of this visualization, note:

  - the numbers/lines in the right imaginary text file will always be
    sequential starting from zero, because of #theme-2.

  - again we could draw arrows matching number to number, and the
    arrow mesh would look just like the arrow mesh we drew above
    (but simplified because now we have disregarded adds and removes).

so, what happens when we take a diff of these two files?

    diff --unified existing-document.txt components.txt

we get:

    --- existing-document.txt xxx
    +++ components.txt xxx
    @@ -1,6 +1,6 @@
    +0
    +1
     2
     3
    -1
    -0
     4
     5

(you can try this with:

    diff --unified test/fixture-files/060-existing-document.txt \
      test/fixture-files/060-components.txt
)

again, this might look like a mess, but it is a more useful mess.

in effect what `diff` has done is decided for us which items we should
"move", and which items can remain stationary. we don't really care by
what rationale it came up with this series of operations; of this we can
remain blissfully ignorant. it is just a black box that we trust has
come up with a reasonable plan to get from list L and list C to list N, part way.

note that crucially, we had to strip the file on the left of any
representation of the breaks between clusters, because we have no
legitimate way of deciding (yet) where and how breaks should be
representated on the right document (yet); we only know of the order
of the items. (in fact, this is sort of the crux of the whole problem,
is deciding where to put the breaks.)

now, what to do with this information?




## the beginning of the final clusterization [#here.M]

at its essence, a diff is a list of line-level edits that get you
from one file to another: add this line, remove these 2 lines, leave these
3 lines alone, advance this many lines, and so on.

but for a variety of reasons, all we are interested in this diff for is
to answer this question: which are the lines that we leave alone?
these lines indicate items that are "stationary", and all the other
items will move.

reviewing some of the lines of the diff:

    +0
    +1
     2
     3
    -1
    -0
     4
     5

we see that '0' is added in one place and removed in another. we see the
same for '1'. because in all cases the "before" and "after" files always
have the same items (just presumably in a different order), every "add"
line will always have a single counterpart "remove" line (somewhere) (and
the converse: every "remove" line has a single counterpart "add" line).

when you encounter items that "move" like this (and each such item
should always have these two lines somewhere), add them to set "V"
(for "moVe"):

    0  1

note too the items that remain stationary (set "S"):

    2  3  4  5

really, these two sets of numbers (er, items) is the only useful
information that we will come away with from the use of `diff`.

now, recall our annotated list L (exactly as presented in [#here.L]):

     A   2
     A'  3
    ---
     B
     C   1
     C'
     C''
     D   0
    ---
     E   4
     F   5

we simplify the clusterization by seeing this as a list of clusters
where each cluster is a list of elements where each element is either
an association or an empty :[#here.M.2] "hole" (not to be confused with
a [#here.L.3] hole) left behind by there being no association for that
section:

    [ 2 3 ] [ - 1 - - 0 ] [ 4 5 ]

what we are leaving behind in this simplification is the identities of
those sections that have no counterpart by practical identity in the
components (a point that we may revisit sometime in the future).

mind you, this clusterization still has something we don't want,
which is those items that must move (we want the items; we just don't
know where we'll put them yet), so:

we further pare down the clusterization by "knocking out" those items
that are in V (that is, the items that move) (or if you like you can
see it as applying a pass-filter for only those items in S (that is,
the items that remain stationary)):

    [ 2 3 ] [ - - - - - ] [ 4 5 ]

now, this clusterization is the first one we've seen so far in this
discussion that can serve as a startingpoint for list N. the items (numbers)
that remain in this clusterization at this point are in the "correct"
"place" for the final output clusterization; that is, they are in the
correct order with respect to each other, and still clusterized.

(the fact that in this case, all the holes are in one cluster, and
that that cluster is composed of only holes; this is only chance!
(honestly, it wasn't intended.))

all that remains to do is to insert the remaining items in list C into this
clusterization in some kind of correct order with aesthetic placement.




## finishing the final clusterization with spongy capsules :[#here.N]

we have two kinds of items waiting to be placed into our clusterization
before we can be finished with this most challenging leg of this effort:

  1) items that moved ([#here.M] set V)
  2) components that are unassociated, i.e "added", which we'll call set "A".

the only hard requirement here is that we place the items in the correct
order with respect to each other, and with respect to the items that are
already in the clusterization.

but, so that we can try to avoid a machine-based distribution of items
that "feels" "lopsided" or "arbitrary", we do something kind of crazy when
deciding exactly where to place the items. we call this crazy something
"capsulization":

recall that we have a clusterization whose clusters are lists of
elements that are either [#here.M.2] holes or associated items:

    +----------------+   +----------------+
    | X |  |  | X |  |   |  | X |  | X |  |
    +----------------+   +----------------+

for this discussion "X" indicates an associated item and " " indicates a
hole. the above depicts two clusters, each five elements long. (this
clusterization is wholly separate from any we have discussed above; its
particular form is designed to demonstrate the subject principle.
we'll refer to this story in tests as #coverpoint2.5 story "B".)

note you could see this as runs of holes separated by runs of items.

  - we define a "capsule" as a contiguous run of one or more *holes*,
    that can *jump over* hops between clusters

so
         +-^-+      +--^--+      +^+     +-..
        /     \    /       \    /   \   /
    +----------------+   +----------------+
    | X |  |  | X |  |   |  | X |  | X |  |
    +----------------+   +----------------+

in the above visualization, consider:
  - each curly top-hat bracket (` /+-^-+\ `) indicates one capsule
  - a capsule will "hop" over a gap between clusters whenever possible
  - a capsule can be as short as one element wide (but not less)
  - a capsule can be many elements (any positive integer) wide

as such, keep in mind too that an individual capsule can overlap
multiple clusters (which we'll call #coverpoint2.6 "story C"):

           +------------------^-----------------+
          /                                      \
    ..-------+   +-----+  +--------+  +--+--+  +--+--..
      | X |  |   |  |  |  |  |  |  |  |  |  |  |  | X
    ..-------+   +-----+  +--------+  +--+--+  +--+--..

this is all to say, there's really no relationship between the
"clusterization" and the "capsulization" of the "document schematic":
each cluster starts and stops independent of each capsule, and
vice-versa.

if you like, this is because clusterization is determined by where
non-participating sections happen in the document; and capsulization
has to do with which participating sections associate with components
in the new component list and which don't. the two are not really
related to each other, spatially or otherwise.

here's one more example, which is derived from our main story ("story A"):

                 +-----^------+
                /              \
    +-------+   +--+--+--+--+--+   +---+---+
    | X | X |   |  |  |  |  |  |   | X | X |
    +-------+   +--+--+--+--+--+   +---+---+

now that we understand *what* capsules are, we must also consider *why*
we capsualize and *how* we capsulize, before we can get back to doing
something with set V (our associated items that moved) and set A, our
new items that need to be added.

we'll answer these questions of "what" and "how" in reverse order:

for the task of realizing "capsulizations" like all of these, we
have created a state-machine-as-directed-graph at fig. 1 (a dotfile
in another file). this is pretty straightforward and not very interesting.



### sidebar: parsing ("how?")

to understand how we "parse" a clusterization to get a capsulization,
hold one "finger" (i.e a pen, a cursor, an imaginary marker) at the left
side of the diagram above (previous section), before the first cluster.
hold another "finger" at the "start/gap" state of the attached figure 1
flowchart.

now move the first finger from left to right until you hit something.
what you hit is the beginning of a cluster. there is a corresponding
type of "transition" for this: "b". and as you will see on the diagram,
there is a corresponding *actual* transition for this type of transition.

so with your *other* finger, follow this indicated transition to the next
state ("head listening"). now, continue to slide your *first* finger to
the right. the next significant thing that happens is you hit an "X".
there is a corresponding available transtion for this (conveniently
eponymous). note this "moves" you to the same state you were already in.

drag your finger to hit the next "X" and see that again, nothing actually
happens in the state machine. but the next significant thing that happens
is when we *leave* the cluster: there is a transition for this. etc.



### so what do we do with these capsules ("why?")?

recall that in a graphic like this (a re-depiction of story B),

         +-^-+      +--^--+      +^+     +-..
        /     \    /       \    /   \   /
    +----------------+   +----------------+
    | X |  |  | X |  |   |  | X |  | X |  |
    +----------------+   +----------------+

the X's signify associated items that didn't move. that is, they were
in the right place when we started and they are still in the right place
now.

recall #theme-2 which holds that we number "associations" in component
order (but not every document section is associated, and not every
component is necessarily associated).

so let's add some numbers to our visual schema that indicate the offsets
of these associations, in a list of all associations:

         +-^-+      +--^--+      +^+     +-..
        /     \    /       \    /   \   /
    +----------------+   +----------------+
    | X |  |  | X |  |   |  | X |  | X |  |
    +----------------+   +----------------+
      0         2             8      12

about this sequence of numbers we just added:

  - this series of numbers is just one of an infinity
    of possible *capsulizations* that this schema could signify.

  - each number represents an offset into a list of *associations*
    between a component item and a document section. (the list represents
    *all* associations between [#here.E] list M and [#here.f.2] list L.)

  - each next number (from left to right) must be greater than the
    previous, because what you are seeing (the X's) is the associations that
    didn't move; and if they were in the correct order to begin with (with
    respect to each other) then their numerical order will reflect that
    (because these numbers track (but not isomorph) the component order).
    (#theme-2).

  - here they must start at zero because this capsulization happens
    to have an association (and not a hole) as its leftmost thing; and
    an association that is leftmost in the clusterization will always
    be leftmost in the list of all associations.

  - the amount that each number jumps from one to the next is an arbitrary
    amount that we selected at didactic-random.

let's look more closely at just how far the jumps are between numbers:

         +-^-+      +--^--+      +^+     +-..
        /     \    /       \    /   \   /
    +----------------+   +----------------+
    | X |  |  | X |  |   |  | X |  | X |  |
    +----------------+   +----------------+
      0         2             8      12
       \       / \           / \     / \
        +1 ct.+   +---5 ct.-+   +-3ct.  +--..


spoiler: the "count" is the second offset minus the first minus one.

look at that first jump from `0` to `2`. because of #theme-2
we know that between the `0` and `2` we've got an association called `1`
to deal with (because associations are numbered sequentially).

that's (coincidentally) a "1-count" of items we've got place somewhere
between the static `0` section and `2` section.

looking at the number of holes in that capsule (the empty squares), we
see that there happen to be two. (it could be way more and it could be
less, but the number of holes in every capsule must be at least one.)

so we've got one association to move (really this is to say "move an
existing section to a new place) and two "holes" across which to spread
it over.

let's look at the second capsule. in this case, there's 5 associations
we will have to place somewhere in the capsule; and to make things more
interesting there is also one hop in the capsule.

in this manner we'll progress along every capsule, taking these notes.
fore each capsule, we want to note:

  - how many associations (the second offset minus the first minus one)

  - how many holes, but also how these runs of holes relate to different
    clusters (i.e represent the hops)

so finally, for the above graphic, the "notes" are conceptually like:

  - 1 association. holes: { 2 }
  - 5 associations. holes: { 1 | 1 }
  - 3 associations. holes: { 1 }

we can FINALLY call each of these the beginnings of a "unit of work".

something something proportional distribution.

possibly disjoint, dangling notes (EDIT):

  - the associations we will distribute into the capsule satisfy
    the need to distribute [#here.M] set V somewhere.

  - before we do that, tho, we've got to take all the new items from
    [#here.N] set A and splice them into the right places so that we
    have a full list of items to distribute within the capsule.

  - in this manner each capsule will distribute "proportionally" its
    items into its holes. all you know is it has at least one hole and
    possibly as few as zero items. remember capsules can span cluters.

  - more items than holes is a "squeeze". less items than holes is
    a "stretch". otherwise "perfect fit".

  - finally, each cluster will need to "be told" that list of zero or
    more items it needs to put into its each "cel."

    (EDIT a "cel" is that piece of a capsule that overlaps with a cluster.)




## the algorithm

(EDIT: this is the ancient one from [cu]. remove this to close #open [#008.E])

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

(EDIT: maybe move this content to [cu] to close #open [#008.E])

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

(EDIT: remove this section to close #open [#008.E])

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




### appendix: indexing a definition of "pluralton"-participating parameters :[#here.p]

the formal parameters of a definition suggest an order with
respect to each other *both* in the context of the whole definition
broadly *and* more narrowly within the context of the (any)
"pluralton" group that each formal parameter aligns. huh?

as such, you could arrange the parameters of the full definition
into N+1 *flat* arrays of formal parameters, where the "first"
(if you like) array is a list of those parameters that have no
"pluralton" affiliation; and the remaining N lists are one list
for each pluralton group, where each group can be held up as a
list of parameters that are in order with respect to each other
as suggested by the order in which all parameters occur in the
defintion. huh?

it's like how the pages of a book have order with respect to each
other, but also they can be grouped in to chapters, and the
chapters have order with respect to each other and also the pages
within a chapter have order with respect to each other. (it's so
understood that it's perhaps confusing to read in these terms.)

in the book analogy, "chapters" are like pluralton groups, and
each page is like each formal parameter.

however, by this selfsame definition we are stating explicitly
that these orders do *not* generally matter. the only way in
which order has significance in the discussion of "pluraltons"
is this:

the order in which *actual* parameters occur determines the order
in which the actual values (normalized) will exist in storage (or
other meaningful representation) but *only* with respect to each
other within each pluralton group (as relevant). huh?

so let's say you have one pluralton group "red" (or "R") and
another pluralton group "blue" (or "B"). let's say we define
a few formal parameters with pluralton affiliations, and we don't
(in our definition) group these parameters close to each other
in regards to their affiliation:

    R1 B1 B2 R2 R3 B3

so (formally) there are three blue's, three red's, and they are
defined in no special order (so the group the parameter belongs
to flickers back and forth "randomly").

now, let's say we receive the following actual parameters
(for whose values we'll just use serial lowercase letters):

    R3:a B2:b R1:c B3:d

that is, we have a value "a" that is an actual value associated
with the formal parameter "R3" (which is in the "red" group),
and so on.

the main point of all this is that in meaningful representation
(i.e "storage", e.g as an action instance or entity), the above
request would be represented like this:

    B: ( B2:b, B3:d )
    R: ( R3:a, R1:c )

that is: within each group, each actual value is A) represented
in the order it occurred in the request and B) associated with
its formal parameter. however, the group lists have no order with
respect to each other. (i.e the fact that we showed the blue's
above the red's is not significant.) huh?

imagine we are buying 7 grocery items: 3 that are frozen and 4
that are not. we will put the frozen items in one plastic bag, and
the non-frozen items in one paper bag. as each item comes one-by-one
off the conveyor belt, we put in in the appropriate bag.

in this story, there are different "orders" (lists of things)
that could be remembered: there's the order that the items came
off the conveyor belt; there's the order that we put each item
into one of the bags (from the perspective of either particular
bag); there's even the order that we first used each bag (which
in this story depends entirely on what is the category of the first
item off the conveyor belt).

well in this analogy, the only order that we "remember" is the
order in which we put each item into each bag. that is, we
"forget" the order the items came off the conveyor belt and
all the rest. also it is not the case that one bag "comes before"
or after the other bag, only that the items have an order within
each bag.

finally, note that it is acceptable for the user to convey multiple
actual values of the same formal parameter:

    R3:a R3:b R3:c

(which would then be modeled in the entity as:)

    R: (R3:a, R3:b, R3:c)

for any combination of actual values for "pluralton" parameters.




## appendix 2: too many kinds of offsets

  - component offset: an index into the list of components in list C.

  - profile offset: an index into the list of every identity profile
    ever created in this invocation. (an entity with the same [#here.H]
    practical equivalence will have the same profile offset whether it's
    in the document or in list C.)

  - associated offset: xx







## document-meta

  - EDIT: get rid of every mention of "survey"

  - EDIT: get rid of "note 25" and its referrent to close #open [#008.E]

  - #history-A.2: 2 historic sections were spliced in
    that were ~6 month old stashes and may somewhat interrupt flow.

  - #history-A.1: begin mostly a full rewrite for
    pluralton-in-git-config persistence

  - #pending-rename: incubating, waiting for a name.
