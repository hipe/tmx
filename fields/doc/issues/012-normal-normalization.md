# the common normalization algorithm


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

(we reference these points in time as :#idea-1).

keep this in mind as we present the below points, because we'll come
back to it. for this latest treatment, we propose that:

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
    or the optional keyword). :#spot-2



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
meta-properties with this same code? (see [#br-001], [#br-022], [#fi-037])

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
