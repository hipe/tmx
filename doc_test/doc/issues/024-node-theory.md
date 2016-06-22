# node thoery :[#025]

## this document..

..is detail towards the more general subject introduced in [#003].




## objective

the big open question of whether and how we support/produce
non-item nodes (that is, tree-like structures like context
nodes). we want to wait until we are near full restoration
to decide how useful it is to support..




## scope

we are irresolute about which course of action to pursue
for those code runs that do not look like examples (A). we could
B) ignore them or C) assume they are shared setup of some kind.

the rest of the discussion here is predicated on the assumption that
(C) we are not ignoring them and that they are some kind of shared
setup. but if we change our minds we should perhaps sunset this whole
document. (all of this may change when we get closer to
synchronization.)




## discussion

first of all, let's assume we're cleanly pairing off discussion runs
and code runs (for they should be cleanly alternating, and per
 #spot-3 they should always start with a discussion run).

there are code runs that look like examples (because they have one
or more lines that look like tests because of the magic copula),
and then there are those that don't. let the former be 'E' (for
"example") and let the others be 'O' (for "other").

given all code runs that exist in toto for a given single comment block,
we here define a comprehensive set of categories that encompasses (by
pattern) all possible sequences formed by the E's and O's of these code
runs:

  • although every comment block has at least one line, not
    all comment blocks have code runs. in such cases this
    sequence-pattern is the empty set [] and will produce no
    nodes from this comment block. (#coverpoint2-1)

  • otherwise (and the comment block produces one or more code runs),
    if it is the case that every code run is an O (and ergo no code
    run is an E) (we'll call this pattern "OO"): although we don't
    love this either way, for now comment blocks in this category
    will produce no nodes. (#coverpoint2-2)

  • otherwise if it is the case that there was at least one code run
    from each category (we'll call this pattern "OE"), again only
    because of this big assuption (C), then this will be expressed
    as a context node, which each constituent item (O or E) in the
    order it was received. (#coverpoint2-3)

    (:axiom-1 is the assertion that above described conditions are
    necessary preconditions for a context node, and may be assumed
    under any such paraphernalia object.)

  • otherwise (and it is the case that every code run is an E
    (and ergo none are of category O)) (we'll call this one "EE"):
    (D) we're gonna try to produce those badboys *flatly*, not in
    a context. (#coverpoint2-4)

we want to be ready to flip (D) around as an option (and for example
make such cases exist in a context node if desired).
again we shouldn't get too carried away until universal re-integration
happens and we can revisit real-world use bolstered by synchronization,
which could end up revealing all this to be a fabricated problem.
