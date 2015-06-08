# the common normalization algorithm

## introduction

the big experimental frontier theory at play during the creation of this
document (as its own node) was in the formulation of this question: how
many different kinds of normalization can we implement with this one
central implementation?

more specifically: we know we have code that we use to normalize an
entity against its formal properties (in whatever arbitrary
business-specific constituency they may assume). can we normalize
incoming formal properties against the (again business-specific)
meta-properties with this same code? (see [#001], [#022], [#044])

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

well the answer is "yes" and "sort-of", resepctively. for (1), we have
kept the logic for applying defaults "hard-coded" so that (a) the
explicit, special treatment that this popular meta-meta-property gets in
the property-related code has a readable counerpart here and (b) sort of
for the "historical" reasons we want to keep this code readable, and
that processing defauls is "more important" than processing ad-hoc
processors (because it's been around longer and is more widely used).

for (3), we *could* try to implement required-ness if we had to through
the API, but we like to aggretate all required-ness failures into one
event when normalizing an entity. do to so is easier if we give this one
its own dedicated code.




## (original in-line comment, here for posterity):

near [#006] we aggregate three of the above concerns into this one
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
