# test suite architecture and conventions :[#001]

## introduction

this fresh introduction (and most of the content nodes below) come after
3 years of working with this homespun test ecosystem. ("quickie" was born
july 2012, "regret" that november.)

during this time some of our test insturmentations and conventions have
changed while others have remained mostly consistent. so the below is
written with the 20-20 hindsight of what we know now that we didn't know
then. as such, these techniques are now infallible.




## test suites are trees, test support is not :[#.A]

our most recent "architecture innovation" is more of a refinement:

around the time that we created what is now [#pl-024] the bundle "fancy
lookup" actor; this came to us as one of these sweeping epiphanies.
leading up to this, some general axioms:

  • yes it is convenient to organize "things" into hierarchies
    generally, and yes test nodes (e.g files) are no exception.

  • furthermore we construct the test suite tree to follow the structure
    of the "application" (or library) code tree, so that to ascertain
    whether or where a code node is covered generally is straightforward
    and unambiguous :[#.B].

    indeed we now derive significant utility from this convention thru
    [#st.002] the "file coverage" utility (b. feb 2012), which relies
    on it.

that much is solid - we still like those points. building from those
ideas, we conceived of [#017] "regret" as "isomorphic layer" on top of
this tree that shoe-horned ad-hoc test-library code into this mix.

in theory it seemed sound: your test code falls naturally into a tree,
and thru plain-old-programming your test-support code should distill out
of there, and then that too can live inside of this tree, right?

wrong.

  • yes it's good to house your test support code inside of the same
    tree as your tests.

  • what's bad is to assume that the clients of these support nodes
    will always only ever be the sibling and child nodes of the point
    where the support nodes live.

the "fancy lookup" actor (above) was a direct salve to this. so to
further qualify the contentious title of this section: we house our test
support nodes in a tree, but the arrangement of this tree should have
negligible impact on the clients of the test support nodes.




## numbering test files [#.C], and regressability in general

we stand by the essential tenet of unit testing design that each test in
a test suite must be an atomic individual unit that does not run
assuming there are any tests "before" it that have passed.

but in practice we also like our test nodes to express somewhat the
dependency graph that their respective code nodes manifest:

("unit", "functional" and "integration" tests are peripherally related
to this point -- they are levels of composition (from little to big)..)

the trees we work with have two dimensions: with the root at the top,
these trees have "depth", but also the nodes of each branch node are
ordered, say from left to right.

we leverage this other dimension to make our tests more "regressable",
which warrants a discussion into what we mean by this neo-logistic
adjective:


### regressability? :[#.D]

fixing a broken test can take anywhere from a few seconds to a few
hours. (whether we have ever spent a few days on a broken test is
something we won't admit to here.) of course, we prefer our broken tests
to fall more on to the former end of the spectrum as opposed to the
latter.

what is best in life is when at any step that you are stuck on a
problem, you have a strategy to help guide you as to what your next
step should be towards rectifying this problem. (come to think of it,
this interesting definition for what our brains are, essentially.)

a good meta-strategy is one where the search space for a solution is
made relatively small relatively quickly. with such a meta-strategy we
can spend less time searching for what the exact problem is and more
time fixing it (or if you prefer, "improving our design", with a nod to
our favorite tautology: "all bugs stem from bad design").

in a perfect world this meta-strategy of ours becomes second nature,
and we solve our problems one after another at a pretty steady clip.
so:

*a good test suite is a tool for reducing that search space at an
optimal speed.*

"good coverage" is only one dimension of this function. another is
whether there is a straightforward "input element" of control that lets
us magnify and de-magnify where we are looking for the problem.

looking at many broken tests all at once has element of noise to it:
if you have 17 (or 137) failing tests, it's almost as useless as having
no tests at all; because these broken tests don't linearize your focus:

[..]




## the reason we access system resources in this manner :[#.E]

it is convenient for tests to be able to write directly to stderr for e.g to
output debugging information. however, littering our code with hard-coded
globals (or constants, that albeit point to a resource like this
(an IO stream)) is a smell: on some systems or at some point in the future
we may want to access these resources via a different means. in some
environments we may want always to ignore such output, or write it to a
logfile.

from within this subsystem rather than accessing such resources "directly",
we instead reference such resources thru wrappers like these, which buys us
some slack for the future, i.e "future-proofs" this a bit.

and if ever we decide that this whole techinque is fundamentally flawed or
needs some kind of re-architecting, we at least have leashes on all the places
that do this.