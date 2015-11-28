require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] models - association - hear" do

    TS_[ self ]
    use :models_association

    it "when all 3 exist already" do
      add_association_to_abstract_graph 'buy almond milk', 'get to the store'
      hear_words %w( buy almond milk depends on get to the store )
      expect_OK_event :found_existing_node
      expect_OK_event :found_existing_node
      expect_OK_event :found_existing_association
      expect_succeeded
    end

    it "create one association (the 2 nodes exist already)" do
      add_nodes_to_abstract_graph 'zip win', 'zip work'
      hear_words %w( zip win depends on zip work )
      expect_OK_event :found_existing_node
      expect_OK_event :found_existing_node
      expect_OK_event :created_association
      expect_succeeded
      scn = TestSupport_::Expect_Line::Scanner.via_string @output_s
      scn.advance_N_lines 3
      scn.next_line.should eql "zip -> zip_work\n"
      scn.next_line.should eql "}\n"
      scn.next_line.should be_nil
    end

    it "create 2 nodes and one association (empty document)" do
      begin_empty_abstract_graph
      hear_words %w( zip win solidly depends on zip work hard )
      expect_OK_event :created_node
      expect_OK_event :created_node
      expect_OK_event :found_existing_node
      expect_OK_event :found_existing_node
      expect_OK_event :created_association
      expect_succeeded
      scn = TestSupport_::Expect_Line::Scanner.via_string @output_s
      scn.advance_N_lines 1
      scn.next_line.should eql "zip [label=\"zip win solidly\"]\n"
      scn.next_line.should eql "zip_2 [label=\"zip work hard\"]\n"
      scn.next_line.should eql "zip -> zip_2}\n"
      scn.next_line.should be_nil
    end

    it "create 2 nodes and one association (single rando node document)" do
      add_nodes_to_abstract_graph 'zip doodle'
      hear_words %w( zip win solidly depends on zip work hard )
      expect_OK_event :created_node
      expect_OK_event :created_node
      expect_OK_event :created_association
      expect_succeeded
      scn = TestSupport_::Expect_Line::Scanner.via_string @output_s
      scn.advance_N_lines 2
      scn.next_line.should eql "zip_2 [label=\"zip win solidly\"]\n"
      scn.next_line.should eql "zip_3 [label=\"zip work hard\"]\n"
      scn.next_line.should eql "zip_2 -> zip_3}\n"
      scn.next_line.should be_nil
    end

    ignore_these_events :wrote_resource

  end
end
