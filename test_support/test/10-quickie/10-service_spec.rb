require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie service" do

    # testing a test framework can certainly present Gödel-lian paradoxes:
    #
    # in order to both achieve good coverage *and* improve the quality of
    # code, we are undergoing this almost full rewrite by re-introducing
    # (while restructuring) our "asset code" line-by-line while following
    # (more or less) "three laws" TDD, and (eventually) checking our
    # coverage with code-coverage tools.
    #
    # in the earliest phase of this rebuild there is, of course, no working
    # quickie in our runtime. using (for example) the latest stable quickie
    # to drive the tests of the development-time quickie is not an option,
    # because we have only one (ruby) runtime, and we have to run the tests
    # in the same runtime as the asset code they are testing.
    #
    # but as soon as we reach the point where quickie could run the body of
    # an example (and we don't mean predicates (no `should`, no `eql`), we
    # just mean the ability to evaluate the body of an `it` block); we refer
    # to this as quickie becoming "self-supporting" because (in theory) it
    # is at this point that we can use quickie to run its own tests..
    #
    # (EDIT: show where this change happens)
    #
    # the reason this is possible without being as meaningless as it sounds
    # is this: in those self-testable tests we only use mechanisms that have
    # been covered by previous tests. so each next test uses what is "proven"
    # to be working by the tests before it. it's a bit like how it's
    # possible to cut metal with metal -- you use a harder metal to cut a
    # softer metal. in this weird analogy, the features covered by previous
    # tests are like the harder metal.
    #
    # so when something is broken it is essential that you either use rspec
    # or run the tests in their "regression order" and focus only on the
    # first failing test.
    #
    # the above explanation is all mostly a mental exercise: when this is
    # finished rspec and quickie can be used equally well to run these. the
    # abve pertains only to development- and regression- time.

    TS_[ self ]
    use :memoizer_methods
    use :quickie

    it "loads" do
      subject_module_ || fail
    end
  end
end
# #born: years later
