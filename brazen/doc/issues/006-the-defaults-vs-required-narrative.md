# the defaults vs. required narrative :[#006]


## introduction

although it's a bit of an oxymoron to have a property with a default
be called "required", we think it's crucial to be able to define all required
fields as such (even those with defaults) so at the last-line-of-defense
required fields check we are given an earlier warning about unexpected nils.

(that is, a required field with a default value of nil (although perhaps
nonsensical depending on the definition of your property class) should
always trigger a missing required field event as appropriate.)




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

  3) of the list of formal properties that have a [#090] nonzero
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
