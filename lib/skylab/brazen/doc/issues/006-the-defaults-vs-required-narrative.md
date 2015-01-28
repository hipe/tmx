# the defaults vs. required narrative :[#006]


## introduction

although it's a a bit of an oxymoron to have a property with a default
be called "required", we think it's crucial to be able to define all required
fields as such (even those with defaults) so at the last-line-of-defense
required fields check we are given an earlier warning about unexpected nils.

(that is, a required field with a default value of nil (although perhaps
nonsensical depending on the definition of your property class) should
always trigger a missing required field event as appropriate.)




## :#specific-code-annotation (originally inline)

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





## history of the problem (sequitor of what?)

this used to be more of a hassle because of an eventing API that has
since been simplified. the way we do it now, there are three distinct
operations that happen in order during the `normalize` call to one
entity:

  1) for each (if any) formal property that houses a defaulting proc,
     if its corresponding actual property is *nil* (not false or other),
     call the defaulting proc and set the actual property to the
     resulting value (whatever it is).

  2) for each (if any) formal property that houses one or more property-
     level normalization procs, run these in order against the actual
     value, issuing a stop signal (that will bubble all the way out) if
     any one of these procs itself issues a stop signal (by resulting
     in false-ish probably).

  3) of the list of formal properties that have a [#fa-024] nonzero
     parameter arity (the list may have a zero length), reduce a list
     of those formal properties whose corresponding actual value is nil
     (not false). this (possibly zero length) list is the list of missing
     required properties.

it *used* to be that some of the aggregative operations like these were
calculated for at the end of the *enhanceent scope*, which looking back
was a problematic way to attempt this.

also it used to be that the defaulting behavior was implemented
differently: for each property with default that was added, we added a
hook for this particular property *into* this particular property.

now, for hooks like these it is enhancement module (and ultimately
entity class) that houses normalization hooks like these and not the
formal property (although we still "physcically" group the code together
into sections corresponding to metaproperties).

all hooks aggregate into one flat array. as well, we put the three steps
into one hand-written normalization hook (added to the flat array of
normalization hooks).

at least three more awful solutions to this solution were proposed in
previous versions of this document.

_
