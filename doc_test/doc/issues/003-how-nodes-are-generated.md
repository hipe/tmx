# how nodes are generated :[#003]

## how paraphernalia fits into the pipeline

to the end of producing test code from comments, the subject sidesystem
models the relevant content of the "asset code" (seen only as a line
stream) in intermediate representations of common test-suite
"paraphernalia" that are intended (on paper at least) to be agnostic
of particular test-suite libraries. (this "stem paraphernalia"
is pseudo-spec'ed at [#025].)



### the two-dimensional breadth of paraphernalia

these objects of paraphernalia represent the various phenomena found in
testing code like "examples" (or "cases" (but don't say "tests")),
assertions (or "predicates" (but again don't say "tests")), contexts
or similar, shared setup ("before blocks", "let" expressions), teardown
routines, and all the other stuff of test suites (much of which we
haven't considered or don't yet know about).

the listing above is just a limited sampling, but its variety is
testament to not only the breadth of such phenomena in general, but also
the breadth of regional variants of the phenomena across different
test-suite solutions.

(it bears mentioning that some of these variants of phenomena are
endemic not just to particular test-suite solutions but to the culture
more generally, being as they are pieces in the the subjective and
ever-moving landscape of evolving best practices and emerging new
patterns, etc.)

fortunately the scope of our job is not to express every phenomena for
every test suite solution, but rather to choose sane "isomorphic"
behavior when deciding how to express a given phenomenon for a given
solution. the "expression pipeline" is designed to this end: it is made
to accomodate this breadth along both these axes; that is, it
has accomodations for a variety of phenomena across a variety of
test-suite solutions.

what we were calling "phenomena" above we call "stem paraphernalia" in
the pipeline (i.e code). each such object of stem paraphernalia gets
translated into an object of paraphernalia particular to the target
test-suite, and it is these final objects that produce the lines of
output.


    +-------+    +--------+    +------+    +------+    +-------+    +-----+
    | lines | => | blocks | => | runs | => | gen. | => | parti.| => |lines|
    +-------+    +--------+    +------+    +------+    +-------+    +-----+
                                                     ^
                                                     |
                                                    here

the "here" indicates where the adapter architecture comes into play so
that output is tailored to the particular target test-suite soultion
(and possibly so that it takes into account other "choices" that would
effect output (but we want to avoid these)).




## just examples

(the README demonstrated a basic translation. (EDIT))




## experimenting with shared setup and depth

code runs that don't have an assertion somewhere in them are called
"unassertive code blocks". [#024] "node theory" expounds on the patterns
that can emerge from these; but the short of it is something like this:

unassertive code blocks aren't useful on their own (according to us),
but we exploit them to produce something that is useful: "shared setup".
(as this is all just one grand experiment at the moment, the particular
paraphernalia of "shared setup" that we have chosen is what we call a
`shared_subject`, which if you're not familiar is something like a `let`
expression but crucially different in one way: assume it's for immutable
data only.)

the broader point here is that this is an experimental higher-level
structure (or compound "node") that can emerge from exploiting higher-level
patterns in the comment block:

    some code

    # with a foobric like this:
    #
    #     foo = BilboBaggins.new
    #
    # you can do this:
    #
    #     foo.has_ring  # => true
    #
    # or you can do this:
    #
    #     foo.wear_cloak  # => :invisible

note how the above has one comment block with three different runs in
it. remarkably (and #experimental'ly) the above makes this:

    context "with a foobric like this" do

      shared_subject :foo do
        BilboBaggins.new
      end

      it "you can do this" do
        expect( foo.has_ring ).to eql true
      end

      it "or you can do this" do
        expect( foo.wear_cloak ).to eql :invisible
      end
    end

(the above is #coverpoint2.3.)

here's some edges while we're here.



### edge case: no assertions

this has no assertive code runs, only unassertive ones:

    # jimmy
    #     1 + 1
    # jammy
    #     2 + 2

the above does not translate to any paraphernalia.
(the above is #coverpoin2-2.)



### edge case: assertions only

if you have a single comment block with several code runs,
each of which has an assertion:

    # jimmy
    #     1 + 1  # => 3
    # jammy
    #     2 + 2  # => 5

you'll get:

    it "jimmy" do
      expect( 1 + 1 ).to eql 3
    end

    it "jammy" do
      expect( 2 + 2 ).to eql 5
    end

(the above is #coverpoint2.4.)

see the above referenced [#024] and then [#010] after it to learn
about patterns of shared setup that can be recognized and expressed.




## (document meta)

• #tombstone: examples of description string transformation, other theory.
• #tombstone: [#011] the 'case' DSL examples (assert structure shape), excellent but furloughed
