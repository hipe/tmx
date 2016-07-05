# magnetic digraph theory

## objective

we are writing this so we know what we need for our counterpart asset
node.



## axiom 1

axiom 1. a function that has multiple products is equivalent to
that set of N functions where there is one function for each of
the N products and each function has the same set of prerequisites
as the original function.

that is, if you have

    A and B via C and D and E

then you (sort of) have:

    A via C and D and E
    (and)
    B via C and D and E

because if you need 'A', then in either case you need the same
things to get 'A'; likewise for 'B'.

likewise in either case, if you have 'C', 'D' and 'E' then you
can make the same things either way. (in the real word the second
way has more utility than the first because there is less waste
for those cases, but we don't concern ourselves with that here.)

if it's still confusing, imagine that you can buy green eggs and
ham for $5. that's

    green eggs and ham via five dollars

if you need (only) green eggs, or you need (only) ham, you can
imagine that you have these imaginary functions:

    green eggs via five dollars
    ham via five dollars

i.e the first function is (sort of) equivalent to the other two.



### then why do it?

wherever we employ the phenomenon of multiple products it's probably
because those products are only ever used together..




## how will we structure our directed graph?

we are making a directed graph, but the graph we can make is
not a simple dependency graph per se. consider:

    A via B and C
    A via D

a naive approach would be to say "A depends on B, C and D". but
at best this is poorly worded. (what it really is is false.)

what is technically correct (the best kind of correct) is to say
"A can be reached thru (B and C), or A can be reached thru D."

this sort of boolean alternation (A depends on this OR that) does
not have a clean isomorph in our directed graphs. however,
losslessly and unambiguously we could make a pretty wild tree of
it (most brackets indicate nodes):

    A  --[ depends on ]->  [ one of these ]
    [ one of these ]   ->   D
    [ one of these ]   ->  [ both of these ]
    [ both of these ]  ->  B
    [ both of these ]  ->  C

maybe another way to say it would be

    A  --[ thru means 2 can depend on ]--> D
    A  --[ thru means 1 can depend on ]--> B
    A  --[ thru means 1 can depend on ]--> C

interestingly there seems to be the same information in both of
these directed graph arrangements. the second one, although more
terse, lacks the grouping of precondition nodes by function; that
is, you have to read every label of every arc before you know what
any given function is made of.





## ok so how will we structure our directed graph?

as we write this we have no idea how we want to depict our data
(which is all part of the fun), but we're gonna imagine it's in
the first way. in order to determine how to structure our graph
internally, it will be useful to imagine how we will go about
depicting the directed graph in terms of the steps we will have
to perform.

we will offer some ultra-soft pseudocode towards that that will
help us decide on the structure we want. but first let's take these
points into account when we do that:

  • in directed graph parlance all we really have (that we care
    about) are nodes, arcs that connect the nodes, labels for
    nodes, and labels for arcs.

  • what in digraphs we call a "node" is called "term" in our [#012]
    unified language. however, we may also say "name" sometimes too.
    but note that we will use "node" and "term" interchangeably here
    (with "node" being used more often because of its visual
    connotation).

  • keep in mind that nodes should never be though of as exclusively
    "product" nodes or "precondition" nodes because what is often
    the product of one function is the precondition of one or more
    others.

  • remember axiom 1.

  • because it is made so often, we say "fwd ref" for "forward reference".

ok, so the pseudocode:

    for the unique set of each name of a product mentioned in the
    upstream (from the collection) in the order each name was
    first encountered,

    if the term has only one function that produces it,

      if the function is monadic,

        render a fwd ref to the node pointing with a
        "comes from" arc to a fwd ref to the requisite.
        (note the function may have multiple products.) #cp1-1

      otherwise (and the function is polyadic),

        if the function has only one product,

          render this in the classic dependency graph
          way, with one "depends on" arc to a fwd ref,
          one arc for each requisite of the function. #cp1-2

        otherwise (and the function has multiple products)

          render a "comes from" with a fwd ref to the function. #cp1-3

    otherwise (and the node has multiple functions that produce it)

      point the fwd ref of the node to a dedicated "one of these"
      branch nodes. then for each function is this list,

        if the function is monadic (even if multiple products),

          just point directly to a fwd ref to the single requisite. #cp1-4

        otherwise (and the function is polyadic),

          if the function only has one product,

            render it now through an "all of these" branch node.
            for each precondition of the function point a
            arrow from the branch node to a fwd ref. #cp1-5

          otherwise (and the function has multiple products)

            point the branch node to a fwd ref to the function. #cp1-6

    semi-finally, for each fwd ref to made to a function
    (they are made when polyadic functions have multiple products),
    render each such function as an "all of these" branch node with
    one arrow pointing to a fwd ref to its each requisite node.

    finally, each fwd-ref to a (business) node can be expressed
    as a node (typically with a plain old label isomorphed from the
    node name (i.e 'term')).
_
