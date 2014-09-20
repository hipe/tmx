# the defaults vs. required narrative :[#006]


## introduction

although it's a a bit of an oxymoron to have a property with a default
be called "required", we think it's crucial to be able to define all required
fields as such (even those with defaults) so at the last-line-of-defense
required fields check we are given an earlier warning about unexpected nils.

(that is, a required field with a default value of nil (although perhaps
nonsensical depending on the definition of your property class) should
always trigger a missing required field event as appropriate.)


## understanding the problem

the problem is a tricky one: we specify that our required fields check hook
be the kind that is added once to the class at the end of the enhancement
scope, because we want it to be aggregate operation that is performed once
at one particular eventpoint (so that we can aggregate all the missing
required fields into one event at one point).

the defaulting hook, however, is a hook that is added once for each
property-with-default that is added to the class. this is a different
hooking mechanism, and as it is implemented it will always get its hooks
added to the client class before the requied hook does, because these
defaulting hooks get added as the properties are added to the class,
whereas the required hook is added once at the end of the scope, and per
our specification, hooks get called in the reverse order from that in
which they were added, so later hooks may know about earlier hooks and
change state accordingly.


## possible solutions

since it is already ugly that we are sort of locked in to what order these
hooks are called in given their shape, one possible solution is to emit
different eventpoints for these different hooks. while we may look
into this in the future, for now we like the "simplicity" of having one
singular "normalize" eventpoint that all such hooks cohabitate.


## our solution

rather than having "requiredness" have to know about "defaultedness"
explicitly, we create this concept of `is_actually_required`, to mean
"is required and has no default".  it's a bit of a workaround, but at
least it is not as ugly and having the requiredness code directly know
about the existence of defaultedness as a concept.


## disadvantages to our solution

the "last-line-of-defense" argument no longer holds because we are
locked into the "wrong" order.


## a more ideal solution

although at first it seems that it would be nice for the order of
meta-properties being used to determine the order that their hooks are called
in, in practice we assume it is unlikely that we want this kind of
knowledge at this level.

alternately it might be nice to have the order that meta-properties are
declared in determine the order that their hooks are called in, but this
would require some drastic re-architecting near the fragile hooking
logic. we could associate a 'meta-property index' with each
meta-property as it is added and associate that with the hook(s) it
defines, and then call the hooks in that order..
