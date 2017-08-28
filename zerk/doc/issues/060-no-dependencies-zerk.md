# no dependencies zerk :[#060]

## table of contents (partial)

  - about the structure of "primary found".. :[#here.A]
  - (see inline) [#here.B]
  - this one weird new argument arity [#here.3]




## objective & scope (overview)

  - tools for implementing a rudimentary API & CLI in one swing
  - one file, no other dependencies




## objective & scope

when you need to make a client that doesn't load a lot of files
(like one that turns on coverage testing or similar), this is a
single-file implementation of the basics needed to make API & CLI




## adjacent reading

see [#053] discussion of feature injection
also see [#br-062] association injection and related.




## about the structure of "primary found" and the :#TWOPLE :[#here.A]

the governing interactive idiom of { primary | operator }
branches (a simplicity we should always aspire to) is that of
interacting with a simple hash with primary/operator normal
symbols as keys and e.g method names (but it could be anything) as
values. as such we must *never* dereference the "trueish item value" in
any way - all we can know about it is it is trueish, and we must
get that value back to the user on a successful lookup. but hold
on to that thought.

this "mental story" of how we resolve features will hold relevance
to us regardless of whether hashes are the actual substrate of
our branches.

because it's more convenient and elegant to work in terms of flat
streams (or scanners in our case) rather than loops inside loops
(or "multidimensional streams", i.e. streams of streams), whenever
we externalize our collection of features as a "flat" stream we've
got to represent a reference back to which of (nonzero positive)
N "injections" there are in the "omni".

this value (which will be an offset) should be superficially
meaningless to the user, except to know that it can be used to
dereference the injection (and then injector). the first value of
a TWO TUPLE is this offset (1).

the decision was made to keep the "found" structure "light" so to
represent the injector we result in the offset of the injection,
rather than placing a handle on "the whole object" in the result
structure (but this could change) (2). for no other reason, doing
it this way keeps inspection dumps of the found structure light and
pretty, at the cost of requiring the user to take one more trip to
the "omni" to dereference components from the found structure as
necessary.

since we implement fuzzy lookups (variously per modality), the user
will need to know what the normal symbol is of the feature that was
resolved. (that is, there is no guarantee that it is the same as the
"normal symbol" that the user sent in.)

this normal symbol is placed as the second component of our tuple
(3). the user does not (and should not) know whether or not fuzzy
matching was engaged to resolve the feature, so this normal symbol
must be in the found structure whether or not fuzzy matching was
employed.  this normal symbol must be in the found structure even
if fuzzy matching is not available in the modality.

the "trueish item value" (mentioned at the opening of this section, totally
meaningless to us) will be included as the third component in this
structure (4), even though it can (by definition) be derived from
the first two components that are in this structure. (we'll assume
the cost of lookup by the substrate is expensive).  :[#here.B]
(the above is more or less [#051.1] restated in a different context.)

using arrays and not structs internally has been shown to be almost 2x
faster ([sli] benchmark #15), so we use array internally for the internal
representation of items when doing a traversal for example for a fuzzy
lookup. (5)

however this approach is proving too brittle and unscalable elsewhere,
so we use our custom struct ("primary found") where it makes sense to.




## the "argument is optional" argument arity :[#here.3]

this is for the (in practice) CLI-only argument arity where a
flag's argument is optional. (that is, it is meaningful to pass
this flag alone, and also meaningful to pass this flag with an
argument.)

  - we avoid this argument arity generally because it doesn't
    isomorph well into other modalities. (in a GUI you should do
    something like a checkbox and a text input that is enabled/
    shown only when the checkbox is checked. in API you would have
    to do some kind of complicated parsing involving two primaries,
    the one being valid only immediately after the other.

  - however we support this argument arity for CLI because it is
    idiomatic as it occurs in parsing `--help [arg]`.

  - success is guaranteed because the scanner is guaranteed to be
    in one of these three states and each state is valid: either
    the scanner is empty or the scanner's head token looks like a
    primary or the scanner's head token does not.

  - see also [#br-002.7] which is exactly about this in CLI (much older text)

  - see also the (ancient) [#014] arity exegesis.




## document-meta

  - #tombstone-A: full rewrite of legacy [fa] content
