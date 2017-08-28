# the new normal :[#012]

## overview

one by one we explore the different broad concerns of normalization,
then we explore how they interplay with one another. then sythesizing
all this, we propose a grand unified theory of normalization, expressed
through a rough-sketch but voluminous body of pseudocode. finally
we critique this model.




## table of contents

(the numbering and ordering rationale here is per [#bs-016.2] conventions.)

  - [#here.a] intro & similar
  - [#here.2] background: analyzing simple, non-general approaches as case studies
  - [#here.d] cursory intro the algorithm (compare [#here.F])
  - [#here.3] cost-benefit analysis of RISC
  - [#here.F] full algorithm in pseudocode
  - [#here.e] is it flexible?
  - [#here.10] provision
  - [#here.appendix-A] definitions of terms
  - [#here.h] the old but still open "N-meta proposition"
  - [#here.K] code notes
  - [#here.i] is the oldest pseudocode, being kept for posterity for now




## brief history

what is reflected here represents work spanning many years and around
seven or so separate facilities that were unified into one. [#037] our
notes from this massive refactoring effort are being kept both for
posterity and to provid a detailed (if noisy) background to the ideas
we present in the subject document.




## this document in context

[#003] and [#004] are spiritually much older than this document, and
generally this one supercedes those. however A) they may still provide
interesting background and B) there is still significant non-overlap,
for which we should cross reference as appropriate.

although this document is higher-level than [#002] generally, we feel
that it may be useful to "come in" to the problem-space from the higher
level of this document (normal normalization) so that we can have an
understanding of why we want modeling of associations at all.

anytime you find something confusing here, or something "seems missing",
always look in [#002] because these two complement each other throughout
most of their content.




## current status of unificiation

  - [#ac-028] still exists
  - [#002] "defined attributes" still exist and do half their own n11n




## background: analyzing simplified, non-general approaches as case studies :[#here.2]

despite having achieved what we consider a "complete" delivery and
integration of our "one ring" algorithm to the many places that use it
in "our universe"; there still exist small pockets of implement-in-place
code that achieve a subset of the same king of thing. for one reason or
another we have left these pockets alone to exist independently of the
subject facility.

these "pockets" are left as-is because (A) they work for the purpose they
are intended with perfect clarity and with negligible cost in terms of
code size; and (B) they give interesting background and (to a developer)
a non-jarring introduction to the kinds of concerns we address with the
general algorithm, and by contrast demonstrate why the "one ring"
normalization is the way it is.




### case study 1: this one simple loop :[#here.2.1]

the code we discuss here appears in [ba], tagged with the subject identifier.

this "pocket"

  - interprets an input stream. it does *not* provide "normalize in place".

  - can *not* provide any [#here.F.B] "extroverted" features (like
    checking for missing requireds), however it..

  - provides what we consider the primary feature of normalizations,
    which is set membership of arguments. (i.e it raises a (could be)
    dedicated exception in the case of unrecognized arguments).

  - cannot parse "softly" (i.e leave the argument scanner as-is when
    encountering an unrecognized scanner head).

  - has the ability to do rudimentary de-facto defaulting (by setting
    default values in your `initialize` method, before the subject method
    is called).



### case study 2: this other simple loop :[#here.2.2]

this "pocket" has all the properties of the immediately previous section,
however it derives the significance of each argument value from its
position rather than requiring qualifying "primaries" to signify the
significance of each value.



### conclusion of the case studies

although these use cases work perfectly well for their intended purposes,
as a more general solution their most glaring shortcoming is that they
don't provide any modeling or delivery of any kind of "required-ness"
(hereafter not hyphenated) check. a secondary shortcoming is is that while
a rudimentary form of defaulting is possible through what might be called
a hack, defaulting that requires any amount of work is not approrpriate by
this means. (defaulting "by-hand" after parsing the arguments may, however,
be suitable in such cases.) nontheless:




## cursory intorduction to the algorithm :[#here.d]

generally the sequence is 1) defaulting, 2) ad-hoc normalization and 3)
requiredness check, but note it it not merely
these steps in sequence. we won't discuss here what these steps actually
mean but you get a pretty good idea of this by the end of the document.
but with more detail:

    if you're dealing with a value from "the outside",

      if it's `nil` and you have defaulting,
        if defaulting succeeds, let this new value be your "working value"
        (otherwise `nil` is still your working value and procede)
        (note that if defaulting fails it does not fail the invocation)

      if [you don't have defaulting or defaulting failed] and you have an ad-hoc normalizer,
        if ad-hoc normalization succeeds (against the outside value)
          let this new value be the "working value"
        otherwise we must withdraw from further processing of this request.

        (note the normalization is still run even if the working value is `nil`)
        (note we never run normalization against a defaulted value)

      if everything's still OK,
      if it's required and your working value is `nil`,
        note the missing required
      otherwise
        write the working value to the "inside".

      (note that an argument of `nil` can overwrite a "good" existing value)

    otherwise (and you're dealing with a "normalize-in-place")

      let the working value be the effective inside value (`nil` when not set),
        noting whether any existing value (possibly `nil`) was actually set.

      if you have defaulting,
        if the defaulting succeeds, let this new value be your working value,
        noting if it succeeded.

      if the association is required and your working value is `nil`
        note the missing required
      otherwise if a value was not previously set or defaulting succeeded
        write the working value to the "inside".

      (we only ever run ad-hoc normalizations against outside values)

    (missing required are aggregated and expressed later)

this is the general idea of the "one ring" algorithm is that there
are these three areas of concern (defaulting, ad-hoc normalization and
requiredness) and they each have to be addressed in a way that works
in concert with the other concerns.




## analysis: cost-benefit analysis of RISC :[#here.3]

if the "ad-hoc normalization" API is worth its salt, then it would
be usable (superficially at least) to implement "defaulting" and
"requiredness" as well. (historic [#004.1.2] gives a sense for what
such a normalization API might look like.) so:

defaulting can be modeled as an ad-hoc normalizer that is pass-thru
for cases other than "known unknown" and "known nil", and *in* these
cases maps the value. requiredness can be implemented as an ad-hoc
normalizer that is pass-thru for all cases other than "known unknown"
and "known nil", and *in* these cases and aggregates a note for failure.
("knownness" has a dedicated document at [#co-004].)

in theory such a "munging" of three concerns in to one sub-facility
could grant us a RISC-like simplification of the set of requirements
for associations (i.e our API). however:

one category of costs associated with this approach is along the
axis of expressiveness/clarity/ease-of-use: it's maybe self-
evident that for most use cases it's more practical to be able
to model an association as simply "being" required rather than
to ask the author to stop and think how to write a normalization
function that expresses and asserts requiredness.

through this same lens we can critique the modeling of default
values: just because defaulting *can* be implemented as a kind of
normalization, it doesn't mean that it necessarily should be.

maybe this is an issue of abstraction: in the domain of authoring
it may make sense to hold these as specific, differentiated meta-
associations. but internally they can be accomplished through a
smaller, shared set of mechanisms.

but in the case of default values, at least, this approach can
lead to a leaky abstraction (i.e a lossy translation): consider
the techinque of injecting default values programmatically into
generated documentation. to accomplish this under the "everything
is a normalization" rubric would be clunky at best. :[#here.3.2]

throughout this document we explore pitfalls like these that can stem
from this "over-munging" approach. we do so specifically across the
concerns of defaulting, ad-hoc normalization and requiredness; pointing
out where such munging can present costs. we could broaden our focus
and apply this same lexicon towards an attempted "munging" of `glob`,
`flag` and "mondaic" associations (all categories of [#014]
"argument arity"); but we hold off on such a critique for now (but
suffice it to say we have over-munged this in the past and we want to
avoid this today.)




## case-study through pseudocode of why we can't have nice munging

a possible pitfall of all this "munging" is that these meta-associations
can be composed and that they are not closed under composition (if
i have that right): "defaulting", "ad-hoc normalization" and "requiredness"
are all meta-associations that need to be at least somewhat cognizant
of each other in ways we now explore.

what follows is three sections, each correspoding to these three
meta-associations. within each section we explore deeply the properties
of that meta-association (the "meta-meta-associations" if you insist);
we imagine requirements for that meta-association, in some cases we
suggest mechanisms (i.e implementation, e.g pseudocode) for the
requirement. in some cases further we identify what we characterize
as false-requirements.

while following along in the three sections (especially their
pseudocode), give consideration to the importance of their order
with respect to each other, in the manner we glanced over cursorily [#here.d]

following these sections, then, we will explore points of "synthesis"
about detailed ways these "meta-associations" can and cannot be allowed
to influence each other.





## step 1 of effecting every association: defaulting :[#here.E.1]

if a "defaulting" function (imagine value) is present, run it
IFF there is no provided value.

this step, then, of effecting a default is skipped (or is it?)
for any defaultant association for which a corresponding
actual value was provided. we are sidestepping the definition
of what exactly we mean by "provided", and whether we mean any
of this at all. these are important distinctions we pick up at
the culmination of [#here.theme-1].

the main thing, then, of effecting defaults is how you "not
skip" the effecting of a default for all those defaultant formal
values for which no actual value was provided. that's really
the essential characteristic of defaulting. we accomplish that
at the culmination of [#here.theme-2].




### (requirement for defaulting: injectable meta-associations)

defaulting is a good example of a meta-association that you might want
to be "injectable": for a CLI you might want to default a path as being
the "current working directory"; but under your API the idea of a
"current directory" might be unapplicable/unusable/a problematic security
risk, and so under such a [#br-002] modality you would want there to be
(virtually if not actually) no defaulting function at all.

for purely historical reasons, we tag discussion of (and desire for)
"meta-association injection" (as described above) with :#masking.

  - this is one good reason why we now don't associate formal
    associations "statically" with (for example) a class is because
    now they are so dynamic.




### (requirement for defaulting: a fail-strategy for this meta-association) :[#here.E.2]

it's also useful to allow a defaulting function to be able to draw on
resources of trivial complexity. for example, we have modeled (in at
least 3 separate applications) a parameter that takes as an argument a
width of a terminal screen in columns. in these cases it's often valuable
to us to have this width default to the width in columns of the current
terminal. however, to accompish this requires a call to an `ncurses`
function, a remote facility that is in no way reliable (for its reasons).

if this requirement is to be accepted (which so far it is), it has these
corollaries:

  - we should model the modeling (sic) of defaulting as something like
    a function that produces the default value to be used, rather than
    just modeling a "default" as a static value that is a baked-in
    part of the association definition. (however [#002.WHERE] allows for and
    gives special treatment to defaults specified as vaules.)

  - (tentative) this default function when executed should have available
    to it the "application stack" (perhaps even including its associated
    operation in its primordial state) so that it can draw on application
    resources in the same manner that operations do.

  - as such, generally we must conceive of defaulting as an auxiliary
    nicety, and not a mission-critical meta-association.

given all this, we must have a failure strategy to allow the defaulting
function to indicate that it was unable to resolve a value for whatever
reason. (we probably don't care about what the reason was, just that a
default value is unavailable.)

(do this by specifying that defaulting functions must result in either
a wrapped value or false-ish, the latter indicating unavailability. if
a defaulting function fails to produce a value, we do not want it to
emit anything, just fail silently as if there is no defaulting function.
a defaulting function that fails is of significance to the developer
but it would only be noise to the end user. (but we reserve the right
to change our minds on this point. scratch that, it should be up to the
application developer; yet another reason why it would be useful to allow
the defaulting proc to "reach" the primordial operation.))





## step 2 of effecting every association: ad-hoc normalization

allowing arbitrary author functions to operate as "ad-hoc normalizers"
is a mostly solved problem (presented fully in historic [#004.1.2]).

but to summarize [#same] and highlight its pertinent characteristics: the
function must take as input a [#co-004] "qualified knownness":

  - this structure allows the function to know and use the name of the
    association it is normalizing, for use in any custom error reporting.

  - this interface is monadic (ergo simple) while still accommodating
    use for the cases of the actual value being existent ("provided")
    or not, variously.

  - more specifically this signature could allow the function to
    distinguish between provided-nil and not-provided, if such a
    distinction were to be useful. (not proscribed here.)

the local participant *can* pass a [#co-001] listener as the block
parameter. whether the participant *must* pass this listener is left
unspecified here (being left to the discrection of the application/
library stack), but the answer is probably "yes".

the function must result in false-ish or a [#co-004] known known. when
false-ish, the local participant is to assume that the normalization
(serialization or validation, etc) failed (or that a related facility
is unavailable), and it must take appropriate action (abandoing all futher
processing of the request, probably).

when the ad-hoc function results in something true-ish (so a known known),
its value is taken to be the *the* normalized, unserialized, valid value
for the component..

we said above that this problem is solved "mostly" because we never
found an ideal fit for the (ostensibly useful) concept of "function
chaining". it would be useful, it seems, to allow the author to model the
normalization "specification" as a chain of normalizing functions.
("first, it has to be an integer. then it has to be in this range..").
indeed, this is how we once implemented the "over-munged" approach
described at the beginning of [#here.3].

while this sounds nice, facilitating something like this carries hidden
cost:

so far, everything we have implemented so far of associations is
amenable to the [#sl-023] "dup-and-mutate" pattern. the meta-association-
values necessary to effect all of this are simple, "atomic" values like
booleans and symbols. but once we allow a relatively complex structure
like a list of functions, this opens the door to new problems:

  - if we dup an association that has a subject array, do we deep-dup
    this array at the time of dup? do we "copy-on-write"? should the
    array always be kept in a frozen state, or should we otherwise
    manage access to it? regardless of how we answer these questions, it
    requires non-trivial custom code and opens up lots of room for error.

  - near #here-4 "meta-association-injection", do we now need an API to allow the
    author to insert new functions at arbitrary locations in the list?
    delete aribtrary functions? so does each function need to have some
    kind of (e.g symbolic name) identifier associated with it?

hopefully we have made evident the pandora's box this can of worms opens
up. but we can sidestep this gordian knot of scope creep by cutting it
thusly: we accept only one such ad-hoc normalizer function. internally the
function can employ "normalization function chaining" or any other
techniques it wants to, but as far as we're concerned we only have this one
normalization function to deal with. this way we pass the buck without
closing the door on all the fun. metaphor! :[#here.D]




## step 3 of effecting every association: requiredness

it may or may not be useful to regard "requiredness" (formally [#014]
"parameter arity") as a special kind meta-attribute. on one hand, it is
perhaps the most centrally important meta-attribute: "no matter what,
don't procede with the operation unless all of the associations
in this list have corresponding actual values." but on the other hand
it is a meta-association that can be seen as almost "outside" of the
intrinsic definition of an attribute, having more to do with the
participant's relationship with the attribute than the attribute
itself.

[ac] develops this deeply by modeling requiredness as a concern of the
"component association" but not part of the formal component itself.
in the subject library we collapse these two ideas into one (the
association is the attribute), which is why we generally always say
"association" and not "attribute" here.

anyway, here in contrast to the past we're going to try something a
little simpler in how we implement this. (we're going to give requiredness
its own "tick" but not its own "pass", more below at [#here.theme-3].)
basically, we *do* munge "requiredness" in with every other kind of meta-
association.

we dodge the question here of [#here.theme-1] what it means for a value
to be present.




## broadening this munging to other modalities (at least two..)

we can broaden our conception of normalization even further by proposing
that it can be conceived of as a superset of unserialization (a.k.a
"unmarshalling"): normalization (by this tautological definition) can
include but must not be limited to any activity where "outside" data (in
its modality-specific representation) is translated in a remote-
modality-appropriate way and then validated so it can be "let" "inside"
the local participant.

(it may be useful to make the distinction that "translating" is
modality-specific, whereas "validating" can be modality-agnostic;
but near #masking this distinction might not necessarily be rigid.)

as we have suggested at [#ac-003.1], we can then try to use the same
underlying mechanism whether our remote source of data is human, file
or other. the referent and its asset have demonstrated this approach as
both viable and useful.

(we will sidestep the problem of how you translate something like a
bytestream (from say a file or network connection) into an "argument
stream". at the "frame" level, we can imagine how an injected argument
scanner would look for, say, a JSON object (it's just name-value pairs,
already converted to primitive types, so the scanner could look something
like an API scanner),..)

more broadly about #masking, it bears mentioning that such a requirement
may or may not put strain on what we build here; for now we're punting on
that as being out of scope. but it's possible that the implementation
of masking would filter associations through some mapper that would
produce associations appropriate for the remote modality, which would
allow the subject facility to remain blissfully ignorant of all of this.




## an overview of problems in synthesis

we have now arrived at a conception of associations that are "normalizers"
in a broad, extroverted sense. not only does the particular association
need to normalize (e.g unserialize, validate) an incoming, provided value;
but:

  - it may need to be notified of and engage code for those associations
    for which no actual value was provided in a sub-concern we call
    "defaulting" #[#here.theme-2].

  - it may need to be notified of and engage code for those associations
    that (in effect) have no effective value (even after defaulting,
    maybe) but "should" have one, in a sub-concern we call "requiredness".

this logical (if not actual) sequence of steps is one-way; i.e., out
of the box (just as with [un]serialization) we cannot automatically
"run backwards" our sequence of steps to prepare some "inside" data
for output to some modality (would that we could!); but it's food
for thought.

it then follows that you must not run normalization on data that is
already "inside" (just as you must not unserialize the same data
twice). an inverted corollary of this is the excellent poka-yoke
discoverd in [#ac-028] ACS's normalization stack, that if a "frame"
"has" a "component", then that component is already valid.
(in a strongly typed language, this would perhaps not need to be a
specified convention at all.) this paragraph is a condensation of
[#here.5.3] a dedicated section on the topic.




## towards synthesis: the interpretation (i.e "meaning") of defaulting vis-a-vis normalization :[#here.5.2]

this is a long-winded but important answer to the question of whether
default values should be run through normalization. (TL;DR: no.)

for parsimony of our association "grammar" (i.e to keep low the number of
meta-associations we have to learn about and remember), we allow that ad-
hoc normalizations (introduced in a previous section) can be used in a
"modality senstive" manner (through #here-4 "meta-association injection",
introduced later). such a utilization of this meta-association makes it
perhaps indiscernable from "unserialization" (or "unmarshalling").

that is, ad-hoc normalization is what will be used (internally) when you
need to parse "incoming" data that is some modality-specific format (what
we'll call "encoded") to the internal format (i.e objects in your runtime,
or what we'll call "decoded").

a simple but common real-world example of this is when you need to parse
some kind of number entered at the command line (or perhaps read from a
file or in a network payload). this value is all but useless to your
runtime unless it is converted from the (possibly) arbitrary string it
"came in" as to a float, integer, etc as appropriate.

the subject facility is designed to make this kind of commonplace
"normalization" an afterthought.

but when it comes to defaulting, the question arises, "if the association
specifies both a defaulting proc and some kind of ad-hoc normalization,
and defaulting is activated, is it appropriate to run the values produced
by defaulting *through* the ad-hoc normalization?"

although we have encountered (and delivered) arrangements where this
"feels" useful, our answer today is: no.

while there is room for debate on this point, it is our "feeling" that
defaulting should generally be "modality agnostic". that is, defaulting
should produce "decoded" not "encoded" values. it is (again) our feeling
that this choice is more intuititve than the alternative, because a
corollary of the alternative is that you could (by default) *not* define
a modality-agnostic default, and it is our assumption that the model
author when modeling a defaulting strategy will generally (but not always)
be thinking of it in modality-agnostic terms.

if the above makes no sense to you (which, it probably doesn't), then
ask yourself: if you wanted to specify that the default value for some
association was the integer `2`, does it "feel" more intuitive to represent
this default as the *integer* `2` or the *string* `"2"`? if you answered
"string" then your feelings are incorrect.

but what we are doing by presenting *integer* `2` as our default is
presenting a "decoded" value (i.e. an internal "object"). remember we are
now conceiving of the whole ad-hoc normalizer sub-facility as indiscernable
from unserialization (unmarshalling). since it is always wrong to try and
unserialize an already unserialized (i.e an already decoded) value, it
follows that it is always wrong to try to normalize a default. whew!

if for whatever reason you wanted the equivalent of this behavior (an
imaginable but as-yet unincountered case), you would have to write your
defaulting proc to do the work "manually" of running whatever value
through the same (or any other) normalization arrangement. you have this
as an option because [#here.E.2] defaulting can now fail.)




## one last point of parsimony :[#here.5.3]

a related point that we need represented "officially" somewhere in this
document is the idea that if a value is already "in" the value store, in
must already be valid.

it's a "parsimonious reduction" that is intended (counter-intuitively,
perhaps) to make this less error prone by reducing the possible states we
have to worry about.

this idea gets more explanation and justification throughout this document
under its tag. also, this same conclusion is reached through its own
justification at [#ac-028.2.3].

it's worth noting here that the degree to which this "problem" is actually
a problem might be determined largely by your platform language's
relationship to a type system.

a corollary of this is that any ad-hoc normalization for any association
must never be run against a value already present in the value store.
in fact, we will broaden the formal name of "value store" to be
"valid value store" just so we don't forget this point.




## full synthesis: soft pseudocode  :[#here.F]

so given all of above facets together (generally, that we traverse
the formal set not just the provided set (A), and (B) that we must
never run normalizers on existent data that is already "inside"),

our overall central algorithm will have these characteristics:

  - that it comprehends over the entire collection (imagine stream)
    of associations once, because it has to to know of any that are
    required, as well as other reasons

  - it will never assign "into" the local participant data that
    might be invalid (according to the representation of validity
    modeled by the particular corresponding association)

  - the degree to which it will validate an already "inside"
    data member of the local participant is particular, and may
    be different than you think. (see algorithm)

we're going to try a new game mechanic meant to reduce the number
of steps and moving parts, in an approach we call "tick not pass"
:[#here.theme-3].

so imagine this:

    index the stream of all associations in this way:
    for each association,

      add it to a hash keyed to its symbolic name.

      for this association, if ANY of:

        - it's required
        - it has an ad-hoc normalizer
        - it has a proc for defaulting

      add a reference (the symbolic name) of this association
      to a hash to be used as a [#ba-061] diminishing pool.
      (we now call such associations "extroverted".) :[#here.F.B]
      (EDIT: it might be that ad-hoc normalizers are not added to the pool, not sure)

    now the formals are all represented as (only) this straightforward
    hash and this simple diminishing pool of "normalizant" formals.

    THEN,

    we will maintain an "ordered set" (hash) that is auto-vivified. (at the
    end, it will be nil unless it was written to.)

    we will maintain a "seen hash".

    for each (if any) provided argument in the (any) argument scanner,

      if you hit an unrecognized association name (or you
      can't resolve an attirbute name (a.k.a "primary");

        we've got to withdraw from further processing this of request.
        (there is no way to continue the parse after this, because in effect
        we don't know how many tokens to skip to get to the next primary.)

      if everything's still OK (and you have a corresponding association),

      as for the concern of argument arity [#here.theme-3], generally it's
      the injected scanner (not us) who determines the mechanics of if and
      how values are advanced off the scanner (or not) variously for the
      special argument arities of `flag` and `glob`.

      however it is we (not the scanner) who knows the characteristics of
      the current association (and it must stay this way) so in effect
      we have to tell the scanner the arity of the current field we are
      processing.

      for `flag`, it's tempting to say that there is no value to receive;
      that its existence alone indicates that it has been engaged. however,
      because we want the flexibility to be able to change the syntax of
      how (for example) the API scanner works here (maybe even leave it up
      to the application), we've got to accept a boolean. more deeply:

      the client may want to effect its syntax so that formal "flags" are
      in effect common, monadic (argument arity "one") fields whose arguments
      happen to be interpretated in a boolean manner. instead, the client
      might want to interpret flags in the way we usually think of them
      (argument arity "zero"); where the presence of the "primary" name
      alone is enough to activate a flag, and it does not consume any
      following argument.

      we want it to be the case that whichever way the (modality) client
      choses to expose a syntax for flags, it is totally opaque to us;
      i.e it must be the case that we don't care. to achieve this level of
      indifference we have to allow for the possibility that the client
      effects flags in the first way, where's it's essentionally a common,
      monadic field. whew! so:

      because the injected scanner can't know that it's a flag it's
      parsing until we tell it, and we can't know that it's a flag it's
      parsing until we know the primary symbol that's at the head, if
      there's ever a possibility that we will want to implement flags
      in the non-flag way we've got to leave the door open for this by
      accepting a meaningful boolean here.

      for `glob`, we think it needs no special handling here. but see below.

      so, can you resolve a value from the injected scanner for this primary?

      if not
        the injected argument scanner should have emitted the complaint.
        withdraw from this request. (this is unrecoverable. it happens
        for example when the argument scanner ends "early". but we don't
        know what the problem is and nor should we care.)

      if everything's still OK (and you have a value for this engagement ("the value")),

      if per the "seen hash" you have seen a provided value for this
      association already in this request

        if the formal is of type `glob`
          TODO is this how we will do this? allow this? probably yes

        otherwise
          we will for now stop immediately and withdraw from futher
          processing of this request because for now as a hard-coded rule
          we will allow no clobbering, even for ostensibly inert expressions
          like repeated activations of a flag; it's a potentially ambiguous
          expression: the user may think etc. we might make this an option
          to allow clobber (so that it behaves like most command line apps
          do), but it's not a high priority.

      otherwise (and you have not yet seen this formal)
        add an entry to the "seen hash" for this formal

      if everything's still OK (and there's no clobber or clobber is OK)

      we're going to do any steps 2 and 3 (not 1) of the canonic formal
      steps here and now, so remove from the diminishing pool any entry
      (boolean `true`) for this formal value. it's OK if this is not the
      first time we have done this for this formal because we dealt with
      any clobbering above (of a sort).

      PROBABLY these steps 2 & 3 will be done in the same manner here
      as we do them later (i.e make it a function). we'll describe them
      here instead of later, arbitrarily.

      step 2: if the association has an ad-hoc normalizer,

        wrap the value in a "qualified knownness". if flag, the value
        will be `true` or `false`. send it (and the listener) into the
        ad hoc normalizer.

        if it succeeded, REPLACE "the value" with the new value as
        produced (as a wrapped "known known") by the normalizer.

        otherwise (and it failed) the normalizer should have emitted
        a complaint. withdraw from futher processing of this request.
        (you could try to continue on to the other actuals/formals, but why?)

      if everything's still OK (and you have a value maybe that's normalized)

      step 3: is it required?

      finally we have come to the point where we have to define
      :[#here.theme-1] exactly what is meant by a value being "provided"
      (i.e "present" or "existent"). this definition can flex (and maybe
      even be configured), but it has to be something. for now:

      these days it is *always* sufficient to say that any value is
      categorized as "provided" IFF it is { "set" or "passed" as
      appropriate } AND NOT `nil`.

        - this is to say that we are indifferent to value being
          { set | passed } as `nil` and not { set | passed }

        - we say "set" when we are checking values already stored in
          the local participant; and we say "passed" when we are referring
          to validating incoming values in a request. (as is evident later,
          we use this same algorithm for both cases.)

      in practice it seems never useful to distinguish between whether
      a value was passed but `nil` rather than a value being not passed.
      we can revisit this as necessary.

      some corollaries of the above:

        - because we are not distinguishing between something being
          not set and that something being set to nil, the "reader" and
          "writer" procs passed into the subject can deal in simple values
          and do not have to be wrap them, making implementation more
          intuitive and independent, at a loss of some detail that we for
          now deem as uninteresting.

        - if your field is "required" and you are expecting say an object
          or a number, and `false` is passed, this *will* pass validation
          unless further specification/validation is employed. (if this
          is ever a problem we could just change a requiredness check
          to assert trueish-ness, and then if you want to be OCD about
          having a required boolean field you may have to write a norm
          function yourself.)

      ANYWAY, if the association is "required" and the corresponding
      actual value (after any normalization) qualifies as "not provided"
      (or "not set") by the working definition, THEN add a symbolic
      reference to this association to the ordered set (not array) and
      continue processing. (why we do not withdraw from futher processing
      at this point will be explained at [#here.J.2].)

      if everything's still OK (and you have a value that's considered
      present and normal), write the value to the property store using
      the "write" proc.

      a particular corollary of the above is worth considering now: what
      happens if the property store ("entity") has something trueish stored
      for this value, and the request had a provided-nil for the value,
      and there's no defaulting proc in the association?

      based on the algorithm as described so far, what happens depends on
      whether the field was required.

        - if it IS required, then the provided-nil trips an aggregated
          (deferred) complaint and the field is not further processed,
          leaving the value in the property store intact. (but complaint
          and withdrawal is guaranteed further on down.)

        - otherwise (and the field was NOT required (and there was no
          relevant normalization on it)), then the provided-nil CLOBBERS
          the value in the property store!

      first of all, keep in mind that if the model author wants a
      provided-nil to engage the association's defaulting proc, then
      that's already what happens. however if the model author wants a
      provided-nil to amount to defaulting to what is already in the
      property store, then (for now) she would have to provide a custom
      ad-hoc normalizer for that association that reads the existing
      value of the entity and sends it back out as the value to default to,
      amounting to the property store ("entity") writing the same value back
      into itself. it's an inelegant but adequate workaround for an odd
      requirement.

    NOW THEN, now that you have traversed each (any) token of the
    (any) argument scanner

    if everything's still OK (notwithstanding any missing requireds you
    are holding on to, which is OK),

    FOR EACH zero or more element in the diminishing pool (remember that?):

      we place a primacy on whether or not the value is already set.
      this is the first thing we check for and based on the outcome of
      this check we will take one of two very different paths for reasons
      that will become clear.

      use the "read" proc to read the value from the local participant.
      as discussed as a corollary of our [#here.theme-1] above (and
      contingent on its specifics as well), the local participant ("entity")
      must munge the case of a value being not set and the value being
      explicitly set to `nil`. (were this not the case this would add
      to the requirements of our reader and writer procs, adding complexity
      to them that we today see as having little value :[#here.F.c].)

      so now we have this *any* value of the any existing component
      in the property store ("entity").

      we will NOT hold on to this value long-term, because it could be
      any arbitray component value (object), and we do NOT run those through
      our ad-hoc normalization, which should always be considered to be
      modality-specific :[#here.theme-6]. rather,

      make a note of whether or not the value qualified as being "set"
      per our [#here.theme-1] definition above. nullify the local variable
      or member variable holding the value just to be safe! (we do not mean
      to nullify the value in the local partipant!)

      now as we said, what we will do hinges largely on whether or not
      this component was "set":

      IF it IS set,

        step 1 (defaulting):           not relevant. even if a defaulting
                                       proc exists, we would not use it
                                       because the field is already set.

        step 2 (ad-hoc normalization): not relevant. even if such a normalizer
                                       is present, we must assume that the
                                       component is already valid (A) and
                                       (B) it's entirely wrong to run objects
                                       through our normalization routines
                                       #[#here.5.3].

        step 3 (required):             not relevant. because we know it is
                                       set, if it is required there is nothing
                                       to do. (there is likewise nothing to
                                       do if it is nt required.)

        as such, when the component is already set we can (and must)
        "pass" on the processing of the association for this field.

        a corollary of this:

          - if (under one property storage model, but substitute your
            favorite) you set the corresponding ivar of this field to
            anything other than `nil` AND there was no provided value for
            it, it will NOT be run through the any ad-hoc normalization
            of the associated association. if you want the equivalent
            of this you would have to do it through plain old programming.
            (again, #[#here.5.3].)

      OTHERWISE (and the field was not set),

        as if in retribution for how easy the other branch was, over
        here we will have a bit of a "many worlds" tree..

        step 1 (defaulting): :[#here.theme-2]:
          if the association has a proc for defaulting, attempt to
          resolve a default value from this proc (remembering that it can
          fail and if it fails we are to ignore the failure as if there
          was no default proc).

          if you resolved a "knownness" here (that is, the call to
          the defaulting proc succeeded, even though its payload value
          might be `nil`), THEN

            reminder: we don't care about any ad-hoc normalization
            here, as justified at [#here.theme-6].

            if this association is required

              if the actual value from the defaulting qualifies as
              existent per [#here.theme-1]

                ACCEPT THE VALUE

              otherwise

                MAKE NOTE OF IT AS A MISSING REQUIRED VALUE
              end

            otherwise (and it's not required)

              ACCEPT THE VALUE
            end

          otherwise (and either there was no defaulting proc or you failed
          to resolve a value from it) then procede to step 2 as if there
          was no defaulting proc.

        step 2 (ad-hoc normalization): if the association has an
          ad-hoc normalizer, process it exactly as described for this step
          way above. as a reminder, it is of course possible for the
          normalization (validation) to fail. such a case should (but
          doesn't necessarily have to) lead to an immediate withdrawal
          from further processing.

          the funny thing here is: the field was not set, so what we
          will be passing into the normalizer is a "qualified knowness"
          of a known unknown. effectively (if not actually), this structure
          holds the name of the association and a boolean indicating that this
          value is a known unknown; and nothing else. if the normalizer
          tries to dereference a would-be value from such a structure an
          exception is raised so well-behaved normalizers always check for
          this "known unknown" case first.

          this arrangement allows the remote normalization facility to
          implement a normalization that effectively ammounts to a
          "defaulting". it is also a definitive answer to the question of
          whether and how you normalize a value when that value is not
          required and it was not provided, but it has ad-hoc normalization.
          (the answer is that the normalization facility has to
          check for this condition explicitly (whether it wants to or not -
          it's the point of qualified knownnesses) and decide for itself
          what to do. typically the remote participant gives all qualified
          known unknowns a "pass" so that if it's not required we keep
          going and if it *is* required, the SUBSEQUENT requiredness check
          will catch it and emit a more appropriately focused complaint.

        if everything's still OK (and you have a value maybe that's normalized)

        step 3 (requiredness check): exactly as described for this same
          step (2 hops) above, if the field is required and our
          "working value" qualifies as being *not* set, add a symbolic
          reference to this association to the ordered set of names
          of missing required fields. note we do *not* withdraw from
          processing here in such a case. again this will be explained at
          [#here.J.2].

    if everything's still OK (and so much could have failed by now),

    FINALLY, now that you have traversed over every zero or more element
      in the diminshing pool, we have only this last effort to do:

    IF there was one or more symbolic reference to required associations
    added to the (any) ordered set of missing required fields,
    emit a single complaint expressing ("splaying") these missing
    required fields.

    :[#here.J.2] (was :[#here.theme-5]) the reason we aggregate all these
    missing required fields into a collection and express them only at the end:

    if we withdrew from all further processing of the invocation at
    every first occurrence of a missing required field, for most
    modality client implementations this "feels" too clunky -- it
    either leaves the user with less information than is useful to
    see the "big picture" of the problem; or it puts too much onus
    on the client to implement UI explaining the "splay" of required
    fields.

    the final result is a boolean indicating whether everything's OK.
    WHEW!




## discussion: is it flexible? :[#here.e]

the central requirement for our "entity-killer" phase of development
(year 7) is that arbitrary new meta-associations can be accomodated
(somehow).

[tm] is the frontier of this sort of thing, and it appears that yes. (EDIT)




## provision - :[#here.10]

[#ze-060.3] explains when we do and don't want to use `argument_is_optional`.
this provision merely states that when an argument is presented (but the
"flag" is nonetheless invoked) we pass `true` as its value.

  - we can't pass `nil` because (under our new simplified way) it gets
    treated indifferently from as if it wasn't passed.

  - to keep things simple we don't deal with [#co-004] wrapped values
    after this point in the pipeline.

  - `true` will work as long as this is CLI-only. when not, something else
    of the above provisions must change.




## appendix A: aggreeing on terms :[#here.appendix-A]

(this is bascially a "unified language".)

depending on whom you ask and what you are doing, any and all of these
terms may be confused:

    association, attribute, property, parameter, field

also:

    token, primary, operator, operation, switch, flag, option, argument

also:

    property store, entity, "local participant", "valid value store"


depending on what you're doing, the distinction may be unimportant.
but to be technically correct (the best kind of correct):

  - the "association" is both a logical concept and a "physical"
    "structure" that consists (typically) of some kind of "name"
    and zero or more meta-data "meta-associations" that describe
    characteristics of the association.

  - the association can have a corresponding "actual value".
    [#002.2] discusses the related idea of formal attributes vs.
    actual attributes.

  - you may also see "[formal] property" used similarly. nowadays
    we say "[formal] property" to mean a association that is part
    of an "entity" (as in "instance of a business model class") a
    opposed to an "operation" ("action", "actor").

  - you may also see "[formal] parameter" used similarly, but to
    refer to a association that is part of an "operation"
    (or "action" or "actor") as opposed to a (business model) entity.

  - "field" does not have a strong distinction apart from these,
    except that there are some idiomatic tendencies governing how
    we typically use this term:

      - "required field" sounds better than "required association", the
        latter using this generalest of all terms "association", and
        so ringing sour from some reasons hinted at below.

      - we don't like the sound of "required property", because we
        associate "property" with "entity", and we think of requiredness
        as being a charactertic (a meta-association) of those associations
        that are part of operations (which we call "parameters"), and
        not entities.

        however A) you'll see this expression in legacy [br] entity code
        where models and actions used (typically) the same entity grammar
        and B) you may see this in new code when we try to specify models
        that generate their own actions.

      - "required parameter" is fine, but "required field" has fewer
        syllables and is a bit of a stronger idiom in the real world.
        in implementation code and the accompanying pseudocd we will say
        "required association" because our normalization algorithm has the
        requirement of normalizing for entities and actions indifferently.

we will simply categorize as "out of scope" any need to differate the
rest except to say:

  - action: the older, [br]-era term for "operation". frameworky, a class
            that usually subclasses another class to expose an application-
            level feature that has some kind of UI expression (what in API's
            we might call an "endpoint").

  - argument: the "value" part of an actual value associated with a
              monadic association, probably. (in CLI, "positional
              argument" is a thing, to stand in contrast to "option".)

  - attribute: up until very recently this term was used for what we
               now call "associations".

  - entity: the "object" or "instance" of a (business) model (class).

  - flag: in CLI, a switch that takes no argument. also a modifier here.

  - "local participant": this is our future-proofy, extra general placeholder
                         term to mean (probably) "the thing that is doing the
                         the thing we are describing." the "property store" probably.

  - modality: defined (vaguely) at [#br-002]

  - monadic: (here) a association that "takes" a single value (as opposed
             to a flag or glob). formally a category of of "argument arity".

  - operation: the newer, [ze]-era term for what we used to call "action".
               operations are not as frameworky as actions. it's any
               "endpoint" that can be reachable thru an iambic API (typically
               powered by some [ze] techniques).

  - operator: in [ze] we use this term to munge primaries and operations,
              which have similar concerns when it comes to parsing.

  - option: always refers to the argument-parsing phenomenon by this
            name in CLI (in contrast to a positional argument). nowadays
            "primary" has come to replace this term, although it's subtly
            different.

  - primary: essential to newer [ze], this is the name-part of an argument
             stream (imagine array)'s surface representation of a particular,
             actual (supposed) instance of an association.
             this term is borrowed directly from (see) `man find`, and bears
             no significant difference from its conception in that program.

  - property store: the "thing" (perhaps imaginary) that is storing the
                    values that are produced by this normalization, also
                    the "thing" (perhaps imaginary) that produces the
                    values representing those attributes that were already
                    known when the normalization started. in practice,
                    an "action" or an "entity" are likely implementors
                    of this, but it could be anything.
                    (we prefer "valid value store" now.)

  - switch: the CLI expression of a "flag". in CLI, interchangeable with
            "flag", sometimes confused with an "option" (which unlike a
            flag takes arguments). we don't use this term except to coincide
            with vendor libraries (and standard libraries) that do.

  - token: typically, any element of an argument scanner. has a bit more
           of a CLI bend to it.





## the N-meta proposition :[#here.h]

the big experimental frontier theory at play during the creation of this
document (as its own node) was in the formulation of this question: how
many different kinds of normalization can we implement with this one
central implementation?

more specifically: we know we have code that we use to normalize an
entity against its formal properties (in whatever arbitrary
business-specific constituency they may assume). can we normalize
incoming formal properties against the (again business-specific)
meta-properties with this same code?

(see also [#034] "entity", [#002.C] "defined attributes", [#037]
"meta attributes".)

crazier still, can we normalize meta-properties against The meta-meta-
properties again with the same code that we use to accomplish the above?

to do so would lend credence to the design axiom that "The
N-meta-property" is a bit of fabricated complexity. that at its essence
we are only ever normalizing entities against models.




## code notes :[#here.K]

### :[#here.K.2]

here we restate the pertinent points of our central algorithm so that
they shadow the structure of our code (mostly), literate-programming-like:

if the value is already present in the "valid value store", then
we must assume it is valid and there is nothing more to do for
this association. ([#here.5.3])

if you succeeded in resolving a default value (which requires
that a defaulting proc is present and that a call to it didn't
fail), then per [#here.E.3] we must assume this value is already
"normalized" and as such we must cicumvent any ad-hoc
normalization. so if we resolved a default (which could possibly
be `nil`), write this value.

if you got this far,

  - there is effectively no corresponding value in the valid
    value store. (either it's set to `nil` or it's not set
    at all.)

  - a default value was not resolved for one of two reasons.

as long as we're treating explicit `nil` indifferently from
"not set" (which we should; yuck if we don't), then we're going to
set it up to look as if the value was explicitly set to `nil`, and
use the same code that we use in those cases (per the law of
parsimony).

if no default, no normalizer, and it's not required; then there's
nothing to do for this field. (there would PROBABLY be no harm in
sending NIL here but we're gonna wait until we feel that we want
it..) #wish [#here.J.4] "nilify" option



### :[#here.K.3]

([#here.J.4] tracks nilification generally, while this section is
related this particular codepoint as an implementation of nilification.)

we know that the effective value is nil. what we don't know
is whether or not it is actually set. (in a struct-based store,
it is a meaningless distinction. but ivar-, hash- and box-based
can make this distinction.) rather than complicate the requirements
for value stores which we [#here.F.c] don't want to do, we just
write `nil` always in these cases, with the chance that it's
sometimes happening unnecessarily.




### :[#here.K.D]

this used to be a distinction that was one-to-one with being a
"glob" association: if the association is a singleton (the default)
then we would complain of unrecoverable ambiguity if you try to
provide any value multiple different times in one request for
association (parameter). however for glob parameters it must be
allowed to specify their value multiple times (it's the point of
globs). now, with our custom parameter model we likewise want to
hold this classification without actually being a glob.




## original in-line comment, here for posterity :[#here.i]

(NOTE although the "one ring" algorithm shares obvious DNA with the
below primordial snippet, the below algorithm is at odds with our
latest version of it in regards to [#here.5.2] whether default values
are run through ad-noc normalizers.)

near [#!006] we aggregate three of the above concerns into this one
normalization hook because a) all but one of the concerns has pre-
conditions that are post-conditions of another, i.e they each must
be executed in a particular order with respect to one another; and
b) given (a), at a cost of some "modularity" there is less jumping
around if this logic is bound together, making it less obfuscated.
the particular relative order is this: 1) if the particular formal
property has a default proc and its corresponding actual value (if
any, `nil` if none) is `nil`, then mutate the actual value against
the proc. 2) for each of the formal property's zero or more custom
normalizations (each of which may signal out of the entire method)
apply them in order to the actual value. 3) if the formal property
is required and the current actual value if any (`nil` if none) is
`nil` then memoize this as a missing required field and at the end
act accordingly. note too given that formal properties are dynamic
we cannot pre-calculate and cache which meet the above categories.
_




## #document-meta

  - :#tombstone-A: early justification for not over-munging
