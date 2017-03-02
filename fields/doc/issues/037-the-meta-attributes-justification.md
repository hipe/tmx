# the meta-properties justification :[#037]

(EDIT: the is a re-housing from [br] and some of the language is old.)

## intro

before reading this, you should understand what [#002] formal properties
are.

the concept of meta-properties is all about tagging your formal
properties with "metadata" that is business specific to your
application. the entity library does not proscribe to you any
meta-properties of its own design. rather, this space is wide open for
you to first create meta-properties and then associate them with your
properties.




## deeper

a "meta-property" is simply a formal property whose purpose is to modify
other formal properties.

our pedagogical example of a meta-property is often "requiredness". but
actually, that is becoming a poor example of a meta-property with the
ideas we will formulate in [#038].

the defining characteristic of meta-properties is that they are
business-specific. (and yes, what constitues "business logic" apart from
lower level mechanics is the same kind of somehwat subjective blurry line
that delineates the boundary between for example a feature and a bug.)

as a bit of an abuse, we could make a case for a checkbox group being
implemented by metaproperties.

if HIPPA-compliance was your thing, and certain fields in certain formed
had to be flagged as needing to comply with HIPPA, this would be an
ideal case for meta-properties. but should the property *library*
provided by [br]  ("entity") need to know what HIPPA compliance is?
the fact that this answer is a resounding "no" is a justification for the
idea of meta-properties: although the idea of HIPPA compliance should not
be built into our property library, being able to work with something like
"HIPPA comliant flagged fields" is live-or-die for applications that
need to.

(EDIT: find a quintessential use-case for m.p's in the wild and examp it
here)




## alternatives ( :.B )

in practice it will sometimes be easier (ETC)




## case study:

this document has been hijacked. it is now for "one ring".




## overview of approach

in three phases, we unify all normalization in our universe into
this "one ring to rule them all".



### phase 1 - survey

essence:

  - we create a "comprehensive survey" of all the normalization algorithms

  - we develop an analytical framework *as* we make the "comprehensive survey"

  - the above two will inform each other, and we will stop the iteration
    between the two when it "feels done". (a 2x2 matrix (like a spreadsheet
    (this was the whole point of [cu])) will allow us to see the "holes"
    of our indexing. we are done when there are no holes in the matrix.)

deliver:

  - spreadsheet (comprehensive survey)




### phase 2 - streamlining each algorithm, one-by-one

essence:

  - we introduce this "streamlining" step where before we did not have
    this as a dedicated step; because we tried a shotgun approach where
    we "streamlined" all algorithms at once, and it broke too horribly
    and we couldn't recover and so just threw away 2 days of work to
    arrive at this roadmap.

  - to "streamline" an algorithm is to (er) normalize the names for
    its parameters and (the harder part) normalize its interface into
    something like a [co] "magnetic by simple model" implemenation.
    (at writing we have what we don't like, which are "externalized",
    "mutable" sessions..)

deliver:

  - a completed punchlist of every facility



### phase 3 - assimilation, one-by-one

essence:

  - the objective of this final phase is that each of the surveyed
    algorithms will "assimilate" *into* the "one ring" facility; which
    is to say the actual "physical" code of these facilities will
    "dissolve" into the "one ring".

  - doing this for more than one facility "at once" is detrimental,
    as we discovered and explained above.

  - we should "line up" the facilities in some order that makes sense,
    using some criteria we haven't arrived at yet. (there's probably
    some algorithm for this where we try to arrive at a "front-load"
    sequence using the information in our comprehensive survey.
    probably each step should add the most new features to the
    "one ring" so that hopefully ground-shaking architectural changes
    will gravitate towards the beginning, so that we throw out less
    work.)

  - when we assimlate the last facility into the "one ring" facility
    we will have some kind of party.

deliver:

  - a completed punchlist of every facility (again)




## an enumeration of pertinent algorithm feature-categories

we will "index" all of our known existing algorithms (there are maybe
six-ish) along the following "axes" that we explain below. we will try
to distill all these feature-categories down into a discrete set of
"provisions", where each "formal provision" is universally unique and
can be answered with a YES/NO against every existing facility.

it may be the case that some formal provision are contingent on others;
i.e. that you will never have a YES for provision B when there is a NO
for provision A. we probably will not represent such contingencies
formally here, but a familiarity with our "feature-space" will allow the
the user to infer such relationships.




## feature-category: awareness of and support for "the big three":

  - is the algorithm aware of (and so implements) defaulting?

  - is the algorithm aware of (and so implements) ad-hoc normalization?

  - is the algorithm aware of (and so implements) requiredness?

the simplest representation of this information is a simple YES/NO for
each of the above three. so note these are all separate questions; the
algorithm can (in theory) support any combination of the three, even
(weirdly) none at all.

(relevant to this discussion is several sections below, where we explore
how all three of the above concerns can be "munged" into one representation
system, but that there's [#here.C] reasons we don't do that.)

but in our survey of all facilities, we will want to further represent
(somehow) the details we explain in the remainder of this section.

there will be variation in the means the algorithm accomplishes those
features that it does. we provide two examples of this now:

as a first example, one algorithm might assume that the association
structure has an `is_required` method. another one might use the [#010]
"RISC-like derivation functions" to ascertian the characteristics of the
associations (i.e meta-associations). a third algorithm might rely on
provided index structures, in which case it won't need to read these
meta-attributes themselves at all.

it is an open question which we will prefer to support. possibly we expose
parameters on our performer for these derivation functions.

as the second example, in the case of "ad-hoc normalizations" there is
variation in how algorithms expose an API for this, which has direct
consequences for how noramlizations are to be expressed by the business
model author. one algorithm wants the client to supply a "box" (ordered
dictionary) of normalization procs. because it's a box, the order of the
normalizations is represented in the argument. (and it's a box and not an
array so that the client can use random-access by-name to swap in or out
various normalizers.) however, we cite several disadvantages to this
approach, and thereby present our current preferred means of exposing
and implementing the meta-association of ad-hoc normalizers [#here.D].




## feature-category: the algorithm's relationship to a scanner/and or entity

  - it's possible for an algorithm to operate against only an "entity"
    (or maybe we'll call it a "value store"); that is, the algorithm does
    not facilitate the parsing of input from an argument stream, but rather
    it uses some structural representation of existing values to effect
    some kind of normalization against.

    such an algorithm would only be useful to effect one or more of the
    "big three". if we follow [#here.theme-4] (which we should) then such
    an algorithm should only be for effecting at most two of the "big three";
    that is, not ad-hoc normalization, but at least one of defaulting and
    and a required-ness check.

  - it's also possible for an algorithm to operate *only* against an
    argument stream (writing, probably, those values *into* some value
    store, but if you prefer you could think of this as the algorithm
    just sending the values into an arbitrary callback method (`_write_`)).

    on its face such an algorithm would at least be useful for what we will
    call a "magnetic set-inclusion parse" off an argument scanner's head;
    that is, keep accepting arguments while the argument scanner head can
    be matched up with an association in some grammar.

    however, the degree to which such an algorithm is useful for the
    "big three" is contingent important semantics question of what you
    mean by each of the big three:

    for such an algorithm to be able to effect defaulting depends on your
    definition of defaulting. such a provision could hypothetically write
    default values the (imaginary) value store, but only to the extent that
    values are not suggested by the argument stream. this would not be able
    to take into account already-present values in some external entity.
    because this strays from the idiomatic understanding of what defaulting
    means, we probably recommend against it.

    for such an algorithm to effect ad-hoc normalization, using our
    current "ideal" conception of the big three, then yes such an algorithm
    is as equally suited as any other for this purpose. (see [#here.theme-4])

    for such an algorithm to effect a required-ness check, againt it could
    do so only against those values suggested by the argument stream, and
    not against some external entity (or other value store). depending on
    the extent to which this conception of "requiredness" strays from the
    idiomatic understanding of it, this provision is likewise not recommended.

  - provision contingencies: it is certainly not the case that every
    algorithm provides both of these features. it is also certainly the
    case that some do (our most recent one at least). however, it's probably
    safe to assume that every algorithm provides at least one of these.




## feature-category: argument-driven vs. association-driven normalization

the feature-category explored above implied this distiction we now
make explicitly. these algorithms always (er) accomplish themselves
through one or both of these techniques.

an algorithm that is argument-driven first of all implies that there
is an input representation to parse from. (for now we casually call
this the "argument stream" but at [#ze-065] we may wish to revise this
idiom.)

an algorithm that is association-driven is necessary any time you want
to implement meta-associations like required-ness and defaulting in the
way that is idiomatically "correct". we will from now on call this
"model-driven normalization", because it requires traversal of all the
associations in the "model", not just those in the "entity". (we will
drill down into this in [#037] eventually.)

in practice a robust facility will employ both of these techinques,
because an algorithm that cannot parse an argument stream is of limited
use; and one that cannot do "model-driven normalizations" likewise
restricts the expressive power of the accompanying meta-grammar.




## feature-category: the algorithm's relationship to indexing/indexes

some algorithms require as parameters already indexed structures (arrays,
probably) corresponding to meta-associations (like requiredness), where each
element of the array represents an association of that classification.

other algorithms may do some kind of call-time indexing of the associations.
(whether or not they actually *do* do such indexing is probably an
implementation detail that we exclude from this provision.)

the provision-contingencies here are mutually exclusive: either the
algorithm does or it does not accept (i.e require) these sorts of
parameters.

as far as pragmatics as it pertains to the "one ring" project, this
feature-category will be a bit tricky to iron-out, because there are
practical reasons to employ both techniques:

  - when using a pure [#here.B] "attributes actor" (which there are
    many), it makes sense (hypothetically if not actually) to index
    these associations "externally" so that definitions are only ever
    indexed at most once per actor definition.

    indeed this is the architectural underpinning of the whole attributes
    actor stack, is that such indexes are arrived at lazily but only ever
    once per definition.

  - when normalizing a request for a typical "application" "action",
    it is strongly recommended that we assume dynamic models. this provision
    allows for advanced features like "association injection", something
    that most applications need eventually. under dynamic models, to index
    the associations before the invocation only adds extra cost.




## omg the table.

  | | | | | | | | | | | | | | | | | | | | | | |
  |f| |d|a|r| |a|a| |e| |R| | | | | | | | | | |
  |a| |e|d|e| |g|g| |x| |I| | | | | | | | | | |
  |c| |f|-|q| |a|a| |t| |S| | | | | | | | | | |
  |i| |a|h|u| |i|i| |e| |C| | | | | | | | | | |
  |l| |u|o|i| |n|n| |r| | | | | | | | | | | | |
  |i| |l|c|r| |s|s| |n| |d| | | | | | | | | | |
  |t| |t| |e| |t|t| |a| |e| | | | | | | | | | |
  |y| |i|n|d| | | | |l| |r| | | | | | | | | | |
  | | |n|o|-| |s|e| | | |i| | | | | | | | | | |
  | | |g|r|n| |t|n| |i| |v| | | | | | | | | | |
  | | |?|m|e| |r|t| |n| | | | | | | | | | | | |
  | | | |?|s| |e|i| |d| |f| | | | | | | | | | |
  | | | | |s| |a|t| |e| |u| | | | | | | | | | |
  | | | | |?| |m|y| |x| |n| | | | | | | | | | |
  | | | | | | |?|?| |?| |c| | | | | | | | | | |
  | | | | | | | | | | | |s| | | | | | | | | | |
  | | | | | | | | | | | |?| | | | | | | | | | |
  | | | | | | | | | | | | | | | | | | | | | | |
  |-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
  |O| | | | | | | | | | | | | | | | | | | | | |     deferred - an event - tagged
  |N| | | | | | | | | | | | | | | | | | | | | |     deferred - an event - tagged
  |M| | | | | | | | | | | | | | | | | | | | | |     red herring. [#br☐057] CLI args parsing
  |L| |Y|N|Y| |N|Y| |-| |Y| | | | | | | | | | | [ac] param n11n
  |K| | | | | | | | | | | | | | | | | | | | | |     [ze] niCLI production
  |J| |.|.|Y| |Y|Y| |-| |-| | | | | | | | | | | USES "G" (was value processing)
  |I| |.|.|.| |Y|Y| |-| |-| | | | | | | | | | | (used to be "lib.rb")
  |H| |N|N|Y| |Y|N| |-| |-| | | | | | | | | | | (function as) (see notes)
  |G| |Y|Y|Y| |N|Y| |-| |-| | | | | | | | | | | (against model) (see notes)
  |F| |N|N|Y| |N|Y| |-| |-| | | | | | | | | | | (the set) (see notes)
  |E| | | | | | | | | | | | | | | | | | | | | |     N/A - specialized (see notes)
  |D| |N|N|Y| |Y|N| |-| |-| | | | | | | | | | | (proxy)
  |C| |Y|N|Y| |N|Y| |Y| |N| | | | | | | | | | | (guy in "A")
  |B| | | | | | | | | | | | | | | | | | | | | | deferred - special - nodeps
  |A| |Y|Y|Y| |Y|Y| |N| |N| | | | | | | | | | | "EK", INDEX ME

    facility O: 2016-11-17 zerk/lib/skylab/zerk/argument-scanner/when/unknown-branch-item.rb
    facility N: 2016-10-26 zerk/lib/skylab/zerk/argument-scanner/when/core.rb:9
    facility M: 2016-04-09 zerk/lib/skylab/zerk/non-interactive-cli/argument-parser-controller-.rb:12
    facility L: 2016-01-21 autonomous_component_system/lib/skylab/autonomous_component_system/parameter/normalization.rb
    facility K: 2016-01-13 zerk/lib/skylab/zerk/non-interactive-cli/core.rb:391
    facility J: 2015-06-08 fields/lib/skylab/fields/attributes/normalization/june-08-2015.rb (was "value processing")
    facility I: 2014-10-31 fields/lib/skylab/fields/attributes/association-index-.rb
    facility H: 2014-10-24 basic/lib/skylab/basic/function/as.rb (function as model)
    facility G: 2014-10-08 fields/lib/skylab/fields/attributes/normalization/october-08-2014.rb (normalization against model)
    facility F: 2013-11-30 basic/lib/skylab/basic/set.rb
    facility E: 2013-07-12 zerk/lib/skylab/zerk/magnetics/formal-parameters-via-method-parameters.rb:275
    facility D: 2013-01-31 basic/lib/skylab/basic/proxy/makers/functional/core.rb
    facility C: 2012-08-20 fields/lib/skylab/fields/attributes/normalization.rb (oldest facility ever, in "A")
    facility B: 2011-08-06 zerk/lib/no-dependencies-zerk.rb
    facility A: "one ring" / "EK". same file as "C"




## special features:

  - facility I: formal reader stack
  - facility H: custom for [br]. if it gives trouble, leave it alone
  - facility G: interesting architecture
                ASSIMILATED
  - facility F: old style but very flexible
  - facility E: use this for all the other guys that do this with platform parameters, maybe
