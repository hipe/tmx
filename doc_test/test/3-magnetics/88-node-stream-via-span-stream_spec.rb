require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] magnetics - NS via SS" do

    TS_[ self ]
    use :files
    include TS_.lib_( :case )::Test_Context_Instance_Methods

    with_big_file_path do

      special_file_path_ :the_how_nodes_are_generated_document
    end

    it "loads" do
      _subject
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

    def _subject
      magnetics_module_::NodeStream_via_SpanStream
    end
  end
end
