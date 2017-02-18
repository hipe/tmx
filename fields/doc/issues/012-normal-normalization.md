# new normal :[#012]

## synopsis

some new freshness is sprinkled on the age-old algorithm of
normalization as we try to approach the dream of a universal,
single solution for this.

this contains the most detailed algorithm in pseudocode yet
of such an approach (of any of the documents in our universe).




## introduction: cost-benefit analysis of RISC

a sufficiently broad implementation of "normalization" can
accomplish "defaulting" and "requiredness" too, which would
grant a RISC-like simplification of the set of requirements
(our API) for formal attributes.

one category of costs associated with this approach is along the
axis of expressiveness/clarity/ease-of-use: it's maybe self-
evident that for most use cases it's more practical to be able
to model a formal attribute as simply "being" required rather than
to ask the author to stop and think how to write a normalization
function that expresses and asserts requiredness.

through this same lens we can critique the modeling of default
values: just because defaulting *can* be implemented as a kind of
normalization, it doesn't mean that it necessarily should be.

maybe this is an issue of abstraction: in the domain of authoring
it may make sense to hold these as specific, differentiated meta-
attributes. but internally they can be accomplished through a
smaller, shared set of mechanisms.

but in the case of default values, at least, this approach can
lead to a leaky abstraction (i.e a lossy translation): consider
the techinque of injecting default values programmatically into
generated documentation. to accomplish this under the "everything
is a normalization" rubric would be clunky at best.

throughout this document we explore pitfalls like these that can stem
from this "over-munging" approach. we do so specifically across the
concerns of normalization, requiredness and defaulting; pointing
out where such munging can present costs. we could broaden our focus
and apply this same lexicon towards an attempted "munging" of `glob`,
`flag` and "mondaic" attributes (all categories of [#014]
"argument arity"); but we hold off on that for now.




## case-study through pseudocode of why we can't have nice munging

a possible pitfall of all this "munging" is that these meta-attributes
can be composed and that they are not closed under composition (if
i have that right): "requiredness", "defaulting" and "normalization"
are all meta-attributes that need to be at least somewhat cognizant
of each other in ways we now explore.

what follows is three sections, each correspoding to these three
meta-attributes. within each section we explore deeply the properties
of that meta-attribute (the "meta-meta-attributes" if you insist);
we imagine requirements for that meta-attribute, in some cases we
suggest mechanisms (i.e implementation, e.g pseudocode) for the
requirement. in some cases further we identify what we characterize
as false-requirements.

while following along in the three sections (especially their
pseudocode), give consideration to the importance of their order
with respect to each other.




## step 1 of effecting every formal attribute: defaulting

if a "defaulting" function (imagine value) is present, run it
IFF there is no provided value.

this step, then, of effecting a default is skipped (or is it?)
for any defaultant formal attribute for which a corresponding
actual value was provided. we are sidestepping the definition
of what exactly we mean by "provided", and whether we mean any
of this at all. these are important distinctions we pick up at
the culmination of [#here.theme-1].

the main thing, then, of effecting defaults is how you "not
skip" the effecting of a default for all those defaultant formal
values for which no actual value was provided. that's really
the essential characteristic of defaulting. we accomplish that
at the culmination of [#here.theme-2].





### (requirement for defaulting: injectable meta-attributes)

defaulting is a good example of a meta-attribute that you might want
to be "injectable": for a CLI you might want to default a path as being
the "current working directory"; but under your API the idea of a
"current directory" might be unapplicable/unusable/problematic, and
so under such a modality you would want there to be (virtually if not
actually) no defaulting function at all.

for no good reason we generally tag concerns like these as #masking.

  - this is one good reason why we now don't associate formal
    attributes "statically" with (for example) a class is because
    now they are so dynamic.




### (requirement for defaulting: a fail-strategy for this meta-attribute)

it's also useful to allow a defaulting function to be able to draw on
resources of trivial complexity. for example, we have modeled (in at
least 3 separate applications) a parameter that takes as an argument a
width of a terminal screen in columns. in these cases it's often valuable
to use to have this width default to the width in columns of the current
terminal, but to achieve this requires a call to an `ncurses` function,
a remote facility that is in no way reliable (for its reasons).

if this requirement is to be accepted (which so far it is), it has these
corollaries:

  - we should model the modeling (sic) of defaulting as something like
    a function that produces the default value to be used, rather than
    just modeling "defaulting" as a static value that is a baked-in
    part of the attribute definition.

  - (tentative) this default function when executed should have available
    to it the application stack (perhaps even including its associated
    operation in its primordial state) so that it can draw on application
    resources in the same manner that operations do.

  - as such, generally we must conceive of defaulting as an auxiliary
    nicety, and not a mission-critical meta-attribute.

given all this we must have a failure strategy to allow the defaulting
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




## step 2 of effecting every formal attribute: ad-hoc normalization

allowing arbitrary author functions to operate as "ad-hoc normalizers"
is a mostly solved problem: the function must take as input a [#co-004]
"qualified knownness":

  - this structure allows the function to know and use the name of the
    attribute it is normalizing, for use in any custom error reporting.

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
false-ish the local participant is to assume that the normalization
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
while this sounds nice, facilitating something like this carries hidden
cost:

so far, everything we have implemented so far of formal attributes is
amenable to the [#sl-023] "dup-and-mutate" pattern. the meta-attribute-
values necessary to effect all of this are simple, "atomic" values like
booleans and symbols. but once we allow a relatively complex structure
like a list of functions, this opens the door to new problems:

  - if we dup a formal attribute that has a subject array, do we deep-dup
    this array at the time of dup? do we "copy-on-write"? either way it
    requires non-trivial custom code and opens up lots of room for error.

  - near "meta-attribute-injection", do we now need an API to allow the
    author to insert new functions at arbitrary locations in the list?
    delete aribtrary functions? so does each function need to have some
    kind of (e.g symbolic name) identifier associated with it?

hopefully we have made evident the pandora's box this can of worms opens
up. but we can sidestep this gordian knot of scope creep by cutting it
thusly: we accept only one such ad-hoc normalizer function. internally the
function can employ "normalization function chaining" or any other
techniques it wants to, but as far as we're concerned we only have this one
normalization function to deal with. this way we pass the buck without
closing the door on all the fun.




## step 3 of effecting every formal attribute: requiredness

it may or may not be useful to regard "requiredness" (formally [#014]
"parameter arity") as a special kind meta-attribute. on one hand, it is
perhaps the most centrally important meta-attribute: "no matter what,
don't procede with the operation unless all of the formal attributes
on this list have corresponding actual values." but on the other hand
it is a meta-attribute that can be seen as almost "outside" of the
intrinsic definition of an attribute, having more to do with the
participant's relationship with the attribute than the formal attribute
itself.

[ac] develops this deeply by modeling requiredness as a concern of the
"component association" but not part of the formal component itself.

anyway, here in contrast to the past we're going to try something a
little simpler in how we implement this. (we're going to give requiredness
its own "tick" but not its own "pass", more below at [#here.theme-3].)

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
or other. the referent and its asset has demonstrated this approach as
both viable and useful.

(we will sidestep the problem of how you translate something like a
bytestream (from say a file or network connection) into an "argument
stream". at the "frame" level, we can imagine how an injected argument
scanner would look for, say, a JSON object (it's just name-value pairs,
already converted to primitive types, so the scanner could look something
like an API scanner),..)

more broadly about #masking, it bears mentioning that such a requirement
may or may not put strain on what we build here; for now we're punting on
that as being out of scope. but it's possible that the the implementation
of masking would filter formal attributes through some mapper that would
produce formal attribues appropriate for the remote modality, which would
allow the subject facility to remain blissfully ignorant of all of this.




## towards implementation: requirements in synthesis

we have now arrived at a conception of attributes that are "normalizers"
in a broad, extroverted sense. not only does the particular formal
attribute need to normalize (e.g unserialize, validate) an incoming,
provided value; but:

  - it may need be notified of and engage code for those formal
    attributes for which no actual value was provided in a facility
    we call "defaulting" #[#here.theme-2].

  - it may need to be notified of and engage code for those formal
    attributes who (even after defaulting, maybe) still have
    "no value" in a facility we call "requiredness".

this logical (if not actual) sequence of steps is one-way; i.e., out
of the box (just as with [un]serialization) we cannot automatically
"run backwards" our sequence of steps to prepare some "inside" data
for output to some modality (would that we could!); but it's food
for thought.

it then follows that you must not run normalization on data that is
already "inside" (just as you must not unserialize the same data
twice). an inverted corollary of this is the excellent poka-yoke
discoverd in [#ac-028] ACS's normalization stack, that if a "frame"
"has" a "component", then that component is already valid. :[#here.theme-4]
(in a strongly typed language, this would perhaps not need to be a
specified convention at all.)




## full synthesis: soft pseudocode

so given all of above facets together (generally, that we traverse
the formal set not just the provided set (A), and (B) that we must
never run normalizers on existent data that is already "inside"),

our overall central algorithm will have these characteristics:

  - that it comprehends over the entire stream of formals once,
    because it has to to know of any that are required, as well
    as other reason

  - it will never assign "into" the local participant data that
    might be invalid (according to the representation of validity
    modeled by the particular corresponding formal attribute)

  - the degree to which it will validate an already "inside"
    data member of the local participant is particular, and may
    be different than you think. (see algorithm)

we're going to try a new game mechanic meant to reduce the number
of steps and moving parts, in an approach we call "tick not pass"
:[#here.theme-3].

so imagine this:

    index the stream of all formal attributes in this way:
    for each formal atribute,

      add it to a hash keyed to its symbolic name.

      for this formal attribute, if ANY of:

        - it's required
        - it has an ad-hoc normalizer
        - it has a proc for defaulting

      add a reference (the symbolic name) of this formal attribute
      to a hash to be used as a [#ba-061] diminishing pool.

    now the formals are all represented as (only) this straightforward
    hash and this simple diminishing pool of "normalizant" formals.

    THEN,

    we will maintain an "ordered set" (hash) that is auto-vivified. (at the
    end, it will be nil unless it was written to.)

    we will maintain a "seen hash".

    for each (if any) provided argument in the (any) argument scanner,

      if you hit an unrecognized formal attribute name (or you
      can't resolve an attirbute name (a.k.a "primary");

        we've got to withdraw from further processing this of request.
        (there is no way to continue the parse after this, because in effect
        we don't know how many tokens to skip to get to the next primary.)

      if everything's still OK (and you have a corresponding formal attribute),

      as for the concern of argument arity [#here.theme-3], generally it's
      the injected scanner (not us) who determines the mechanics of if and
      how values are advanced off the scanner (or not) variously for the
      special argument arities of `flag` and `glob`.

      however it is we (not the scanner) who knows the characteristics of
      the current formal attribute (and it must stay this way) so in effect
      we have to tell the scanner the arity of the current field we are
      processing.

      for `flag`, it's tempting to say that there is no value to receive;
      that its existence alone indicates that it has been engaged. however,
      because we want the flexibility to be able to change the syntax of
      how (for example) the API scanner works here (maybe even leave it up
      to the application), we've got to say this: we have to accept a
      boolean, so that we are free to interpret "flag" as effectively
      meaning "boolean argument"..

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
      attribute already in this request

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

      step 2: if the formal attribute has an ad-hoc normalizer,

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

      ANYWAY, if the formal attribute is "required" and the corresponding
      actual value (after any normalization) qualifies as "not provided"
      (or "not set") by the working definition, THEN add a symbolic
      reference to this formal attribute to the ordered set (not array) and
      continue processing. (why we do not withdraw from futher processing
      at this point will be explained at [#here.theme-5].)

      if everything's still OK (and you have a value that's considered
      present and normal), write the value to the property store using
      the "write" proc.

      a particular corollary of the above is worth considering now: what
      happens if the property store ("entity") has something trueish stored
      for this value, and the request had a provided-nil for the value,
      and there's no defaulting proc in the formal attribute?

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
      provided-nil to engage the formal attribute's defaulting proc, then
      that's already what happens. however if the model author wants a
      provided-nil to amount to defaulting to what is already in the
      property store, then (for now) she would have to provide a custom
      ad-hoc normalizer for that formal attribute that reads the existing
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
      to them that we today see as having little value.)

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
                                       (for now) (per [#here.theme-4]).

        step 3 (required):             not relevant. if the field is required,
                                       we know it is set. either way there is
                                       no work to do here.

        as such, when the component is already set we can (and must)
        "pass" on the processing of the formal attribute for this field.

        a corollary of this:

          - if (under one property storage model, but substitute your
            favorite) you set the corresponding ivar of this field to
            anything other than `nil` AND there was no provided value for
            it, it will NOT be run through the any ad-hoc normalization
            of the associated formal attribute. if you want the equivalent
            of this you would have to do it through plain old programming.

      OTHERWISE (and the field was not set),

        as if in retribution for how easy the other branch was, over
        here we will have a bit of a "many worlds" tree..

        step 1 (defaulting): :[#here.theme-2]:
          if the formal attribute has a proc for defaulting, attempt to
          resolve a default value from this proc (remembering that it can
          fail and if it fails we are to ignore the failure as if there
          was no default proc).

          if you resolved a "knownness" here (that is, the call to
          the defaulting proc succeeded, even though its payload value
          might be `nil`), THEN

            reminder: we don't care about any ad-hoc normalization
            here, as justified at [#here.theme-6].

            if this attribute is required

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

        step 2 (ad-hoc normalization): if the formal attribute has an
          ad-hoc normalizer, process it exactly as described for this step
          way above. as a reminder, it is of course possible for the
          normalization (validation) to fail. such a case should (but
          doesn't necessarily have to) lead to an immediate withdrawal
          from further processing.

          the funny thing here is: the field was not set, so what we
          will be passing into the normalizer is a "qualified knowness"
          of a known unknown. effectively (if not actually), this structure
          holds the name of the attribute and a boolean indicating that this
          value is a known unknown; and nothing else. if the normalizer
          tries to dereference a would-be value from such a structure an
          exception is raised so well behaved normalizers always check for
          this "known unknown" case first.

          this arrangement allows the remote normalization facility to
          implement a normalization that effectively ammounts to a
          "defaulting". it is also a definitive answer to the question of
          whether and how you normalize a value when that value is not
          required and it was not provided, but it has a normalization
          "routine". (the answer is that the normalization facility has to
          check for this condition explicitly (whether it wants to or not,
          it's the point of qualified knownnesses) and decide for itself
          what to do. typically the remote participant gives all qualified
          known unknowns a "pass" so that if it's not required we keep
          going and if it *is* required, the SUBSEQUENT requiredness check
          will catch it and emit a more appropriately focused complaint.

        if everything's still OK (and you have a value maybe that's normalized)

        step 3 (requiredness check): exactly as described for this same
          step (2 hops) above, if the field is required and our
          "working value" qualifies as being *not* set, add a symbolic
          reference to this formal attribute to the ordered set of names
          of missing required fields. note we do *not* withdraw from
          processing here in such a case. again this will be explained at
          [#here.theme-5].

    if everything's still OK (and so much could have failed by now),

    FINALLY, now that you have traversed over every zero or more element
      in the diminshing pool, we have only this last effort to do:

    IF there was one or more symbolic reference to required formal
    attributes added to the (any) ordered set of missing required fields,
    emit a single complaint expressing ("splaying") these missing
    required fields.

    :[#here.theme-5] the reason we aggregate all these missing required
    fields into a collection and express them only at the end:

      - if we did them piecemeal one-by-one as they happen, for most
        modality client implementations this "feels" too noisy, and it's
        such a common occurrence that it's not fair to require the
        implementation to aggregate summarize these emissions herself.

      - if we withdraw at the first missing required field, then (for some
        modalities) it makes for a poor using experience, leaving the user
        to have to be notified one-by-one of each missing required field
        in a drawn-out, iterative manner.

    the final result is a boolean indicating whether everything's OK.
    WHEW!




## discussion: is it flexible?

the central requirement for our "entity-killer" phase of development
(year 7) is that arbitrary new meta-attributes can be accomodated
(somehow).




## appendix A: aggreeing on terms

depending on whom you ask and what you are doing, any and all of these
terms may be confused:

    attribute, property, parameter, field

also:

    token, primary, operator, operation, switch, flag, option, argument

also:

    property store, entity, "local participant"


depending on what you're doing, the distinction may be unimportant.
but to be technically correct (the best kind of correct):

  - the "formal attribute" is both a logical concept and a "physical"
    "structure" that consists (typically) of some kind of "name"
    and zero or more meta-data "meta-attributes" that describe
    characteristics of the formal attribute. we say "formal" to
    distinguish it from an "actual" attribute (value); a distinction
    that has a dedicated document at [#025] (in [#002])).

  - you may also see "[formal] property" used similarly. nowadays
    we say "[formal] property" to mean a [formal] attribute that is part
    of an "entity" (as in "instance of a business model class") a
    opposed to an "operation" ("action", "actor").

  - you may also see "[formal] parameter" used similarly, but to
    refer to a [formal] attribute that is part of an "operation"
    (or "action" or "actor") as opposed to a (business model) entity.

  - "field" does not have a strong distinction apart from these,
    except that there are some idiomatic tendences governing how
    we typically use this term:

      - "required field" sounds better than "required attribute", the
        latter using this generalest of all terms "attribute", and
        so ringing sour from some reasons hinted at below.

      - we don't like the sound of "required property", because we
        associate "property" with "entity", and we think of required-ness
        as being a charactertic (a meta-atribute) of those attributes
        that are part of operations (which we call "parameters"), and
        not entities.

        however A) you'll see this expression in legacy [br] entity code
        where models and actions used (typically) the same entity grammar
        and B) you may see this in new code when we try to specify models
        that generate their own actions.

      - "required parameter" is fine, but "required field" has fewer
        syllables and is a bit of a stronger idiom in the real world.
        in implementation code and the accompanying pseudocd we will say
        "required attribute" because our normalization algorithm has the
        requirement of normalizing for entities and actions indifferently.

we will simply categorize as "out of scope" any need to differate the
rest except to say:

  - action: the older, [br]-era term for "operation". frameworky, a class
            that usually subclasses another class to expose an application-
            level feature that has some kind of UI expression (what in API's
            we might call an "endpoint").

  - argument: the "value" part of an actual value associated with a
              monadic formal attribute, probably. (in CLI, "positional
              argument" is a thing, to stand in contrast to "option".)

  - entity: the "object" or "instance" of a (business) model (class).

  - flag: in CLI, a switch that takes no argument. also a meta-attribute here.

  - "local participant": this is our future-proofy, extra general placeholder
                         term to mean (probably) "the thing that is doing the
                         the thing we are describing." the "property store" probably.

  - monadic: (here) a formal attribute that "takes" a single value (as opposed
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

  - primary: essential to newer [ze], this is the name-part of an actual
             attribute (expression) as it appears in an argument scanner.
             this term is borrowed directly from (see) `man find`, and bears
             no significant difference from its usage there.

  - property store: the "thing" (perhaps imaginary) that is storing the
                    values that are produced by this normalization, also
                    the "thing" (perhaps imaginary) that produces the
                    values representing those attributes that were already
                    known when the normalization started. in practice,
                    an "action" or an "entity" are likely implementors
                    of this, but it could be anything.

  - switch: the CLI expression of a "flag". in CLI, interchangeable with
            "flag", sometimes confused with an "option" (which unlike a
            flag takes arguments). we don't use this term except to coincide
            with vendor libraries (and standard libraries) that do.

  - token: typically, any element of an argument scanner. has a bit more
           of a CLI bend to it.


#=== OLDER: (needs EDIT)

## work in progress preface

at the moment we are in the middle of a long cluster of work that will
try to unify all algorithms under this family strain to here. this
doument moved here from [br]. when the unification is complete, this
section of text will be removed and this document will somehow
assimliate [#ac-028]  (and our node assimilate it).



## temporary scratch space

formal attribute sets can have formal attributes that define default
values. also they can have formal attributes that somehow express their
"requiredness" (refered to formally as "parameter arity"). here we
explain what these classification mean and how they are related.

implementing "requiredness" involves chosing some point in time as a
"normalization point" and at that point determining (by some criteria)
which of the required formal attributes have no corresponding actual
value in the "attribute store" (or "entity" if you like).

similarly implementing defaulting involving chosing some point in time
as a "normalization point" at at that time iterating through the formal
attributes with defaults and by some criteria deciding whether to set
the default value in the attribute store.

(we reference these points in time as :[#here.A].)

keep this in mind as we present the below points, because we'll come
back to it. for this latest treatment, we propose that:

(EDIT: still good but need to accomodate flip/flip)

  • every formal attribute is either required or optional.

  • our syntax supports only an `optional` flag (not a `required`
    flag).

  • to define a default for an attribute implies that the attribute is
    optional. (i.e all attributes with defaults are optional.)

  • it is therefor redundant to define an attribute as `optional` and
    to define a default for it. we will make it a syntax error to do so,
    to enforce consistency in user definitions. (:#here)

  • insomuch as we "nilify" optionals, THEN defining an attribute as
    `optional` is equivalent to defining that it has a default of `nil`.

  • we may then forbid a default of `nil` for this same reason
    (insomuch as we "nililfy" optionals.) (:#here-2)

  • IF every formal fits into one of the three categories:
      * required,
      * explicitly "defaultant" because the defaulting is defined -or-
      * implicitly defaultant because it is `optional`;
    THEN every formal is either required or effectively defaultant (:#here-3).

as suggested but not synthesized above, formal attribute sets that
involve defaulting and/or requiredness are ones that need this
"normalization point" to be signalled externally (i.e with a method
call). the attribute store whose formal attribute set does not involve
either of these need not concern itself with this extra normalization step.

  • (experimental) if a given "formal attributes" set stipulates neither
    defaults nor any optionals (which we are treating as the same kind
    of thing as hinted at above), THEN we are not going to invoke this
    normalization step "automatically". NOTE that this may be
    counter-intuititve. since there is an `optional` flag but no
    `required` flag in this syntax, not to indicate an attribute as
    optional would seem to imply that it is required. HOWEVER we only
    invoke the "normalization step" automatically IFF the relevant
    modifiers are employed by the definition (default related keywords,
    or the optional keyword). :[#here.B]



### implementing the above: indexing

if a formal indicates that it is `optional`, these things should happen:

  • the "parameter arity" should be changed from the default of `one`
    (required) to `zero_or_one` (optional).

  • pursuant to the above point #here that explains how these things
    should be mutually exclusive, this act should "lock out" (in terms
    of the state of the formal attribute as it is being defined) further
    attempts to give it a default (or repeat the designation of `optional`).

  • some parsing parent session should be notified that The Pass
    should be invoked.

if a formal indicates that it has a default (and there are at least two
forms we should probaly support), these things should happen:

  • the default should be stored in some normal way (probably as a
    `default_proc`).

      + its representation should express that a default has been
        provided.

      + its representation should express (on demand) what the default
        value is.

  • just for #here-2, we may signal a syntax error if the default is
    defined by value and that value is `nil`.

  • like above, this act should "lock out" subsequent attempts either to
    define a default (again) or to signal that this formal attribute is
    optional.

  • some parsing parent session should be notified that The Pass
    should be invoked.



### if "The Pass" should be invoked:

for perceived efficiency, how we index these formal attributes is
determined entirely by how The Normal Normalization will be performed.

before and during :"The Pass":

  • every formal attribute is either required or is effectively
    "defaultant" per #here-3.

  • once a formal attribute is *done* being defined, you know if it
    is "defaultant". (either the `optional` flag was used or a default
    was defined somehow.) (actually you can know in advance of it being
    done that it will need to be indexed - you can know it the moment
    you interpret the relevant syntax element.)

  • all formal attributes that are not in the category described by
    the above point are required; but we don't know that we need to
    index them until we hit any that are in the above category.

"single pass indexation" :.. just do.

the normal normalization will be described inline.




## (previous) introduction

the big experimental frontier theory at play during the creation of this
document (as its own node) was in the formulation of this question: how
many different kinds of normalization can we implement with this one
central implementation?

more specifically: we know we have code that we use to normalize an
entity against its formal properties (in whatever arbitrary
business-specific constituency they may assume). can we normalize
incoming formal properties against the (again business-specific)
meta-properties with this same code? (see [#034], [#br-022], [#fi-037])

crazier still, can we normalize meta-properties against The meta-meta-
properties again with the same code that we use to accomplish the above?

to do so would lend credence to the design axiom that "The
N-meta-property" is a bit of fabricated complexity. that at its essence
we are only ever normalizing entities against models.




## the algorithm, in brief

1) apply defaults before other normalizations (so that default
   values themselves get normalized, e.g validated).

2) apply other normaliztions other than the required-ness check.

3) apply the required-ness check.




## analysis of the algorithm

this algorithm was implemented fully under the light of [#ba-027] our
universal standard API for normalization (which we like because it's
simple and universal); however when we hold up the above 3 steps to this
rubric one might wonder why we haven't simplfied our implementation further:

  • for (1), couldn't you implement defaulting with the same logic
    that you use to implement the ad-hoc normalizers of (2)? (after
    all, by design ad-hoc normalizers are certainly capable of doing
    the kind of value mutation that a default is able to do)

  • for (3), the same idea: if you encounter a formal property that is
    required that has not been provided, couldn't you signal a
    normalization failure in the same way that ad-hocs do?

well the answer is "yes" and "sort-of", respectively. for (1), we have
kept the logic for applying defaults "hard-coded" so that (a) the
explicit, special treatment that this popular meta-meta-property gets in
the property-related code has a readable counerpart here and (b) sort of
for the "historical" reasons we want to keep this code readable, and
that processing defaults is "more important" than processing ad-hoc
processors (because it's been around longer and is more widely used).

for (3), we *could* try to implement required-ness if we had to through
the API, but we like to aggregate all required-ness failures into one
event when normalizing an entity. do to so is easier if we give this one
its own dedicated code.




## (original in-line comment, here for posterity):

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
