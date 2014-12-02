require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - intermediate streams - NS via SS" do

    extend TS_

    include TS_::Case_::Test_Context_Instance_Methods

    with_big_file_path do
      TestSupport_.dir_pathname.join( 'doc/issues/014-how-nodes-are-generated.md' ).to_path
    end

    it "loads" do
      subject
    end

    it "a minimal example of generating an example" do
      expect_case :a_minimal_example_of_generating_an_example
    end

    it "an example of a minimal before block" do
      expect_case :an_example_of_a_minimal_before_block
    end

    it "an example of the let hack" do
      expect_case :an_example_of_the_let_hack
    end

    def subject
      Subject_[]::Intermediate_Streams_::
        Node_stream_via_comment_block_stream::Node_stream_via_span_stream__
    end
  end
end
