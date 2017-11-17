require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - hear - association" do

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :operations_legacy_methods_for_hear

    # temporary in this file: DEBUG_ALL_BY_FLUSH_AND_EXIT

# (1/N)
    context do
    it "when all 3 exist already" do
        tuple_ || fail
      end

      it "(did not write)" do
        want_did_not_write__
      end

      shared_subject :tuple_ do
      add_association_to_abstract_graph 'buy almond milk', 'get to the store'
      hear_words %w( buy almond milk depends on get to the store )
      want_OK_event :found_existing_node
      want_OK_event :found_existing_node
      want_OK_event :found_existing_association
      want_succeed
      end
    end

# (2/N)
    context do
    it "create one association (the 2 nodes exist already)" do
        want_did_write_ || fail
      end

      shared_subject :tuple_ do
      add_nodes_to_abstract_graph 'zip win', 'zip work'
      hear_words %w( zip win depends on zip work )
      want_OK_event :found_existing_node
      want_OK_event :found_existing_node
      want_OK_event :created_association
      want_succeed
      end

      it "(content, partial)" do
      scn = build_scanner_via_output_string_
      scn.advance_N_lines 3
      scn.next_line.should eql "zip -> zip_work\n"
      scn.next_line.should eql "}\n"
      scn.next_line.should be_nil
      end
    end

# (3/N)
    context do
    it "create 2 nodes and one association (empty document)" do
        want_did_write_ || fail
      end

      shared_subject :tuple_ do
      begin_empty_abstract_graph
      hear_words %w( zip win solidly depends on zip work hard )

      want_OK_event :created_node
      want_OK_event :created_node
      want_OK_event :created_association
      want_succeed
      end

      it "(content, partial)" do
      scn = build_scanner_via_output_string_
      scn.advance_N_lines 1
      scn.next_line.should eql "zip [label=\"zip win solidly\"]\n"
      scn.next_line.should eql "zip_2 [label=\"zip work hard\"]\n"

      # #history-A.1:
      scn.gets == "zip -> zip_2\n" || fail
      scn.gets == "}\n" || fail
      scn.gets and fail
      end
    end

# (4/N)
    context do
    it "create 2 nodes and one association (single rando node document)" do
        want_did_write_ || fail
      end

      shared_subject :tuple_ do
      add_nodes_to_abstract_graph 'zip doodle'
      hear_words %w( zip win solidly depends on zip work hard )
      want_OK_event :created_node
      want_OK_event :created_node
      want_OK_event :created_association
      want_succeed
      end

      it "(content, partial)" do
      scn = build_scanner_via_output_string_
      scn.advance_N_lines 2
      scn.next_line.should eql "zip_2 [label=\"zip win solidly\"]\n"
      scn.next_line.should eql "zip_3 [label=\"zip work hard\"]\n"
      scn.next_line.should eql "zip_2 -> zip_3}\n"
      scn.next_line.should be_nil
      end
    end

    # #local-history: :#here3:
    ignore_these_events :wrote_resource
  end
end

# #history-A.1 some time before this commit, the tagged test case(s) resulted
#   in documents that differred superficially from those that result here
#   while importantly, the underlying structure of the produced graphs was
#   the same as it is now.
#
#   they differed in that in the current version, there is a newline
#   character between the last association and the closing '}' curly, whereas
#   in the previous green version of this file the generated documents had
#   final lines that looked something like this: "foo -> bar}\n".
#
#   we suspect that this change owes to us either having silently broken
#   behavior near document element prototypes or having silently fixed it;
#   but since this change is cosmetic and does not effect the to the
#   structure of the expressed graph (to say nothing of the fact that this
#   issue is well outside the scope of the subject silo), we are for now
#   ignoring it, beyond writing this lengthy comment about it.

