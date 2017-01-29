require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - example intro" do

    # temporary note: this test was introduced now only to confirm that we
    # can run multiple tests with r.s by naming them on the command line
    # (these seems fairly certain). this is something we may or may not
    # try to support with core quickie (as opposed to the quickie "recursive
    # runner") when we flip to self-support pretty soon here (at -0.847)

    TS_[ self ]
    use :memoizer_methods
    use :quickie

    it "hi." do
      1.should eql 1
    end
  end
end
# #born: years later
