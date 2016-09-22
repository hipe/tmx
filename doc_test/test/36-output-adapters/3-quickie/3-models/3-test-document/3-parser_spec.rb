require_relative '../../../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] output adapters - [quickie first test file]" do

    TS_[ self ]
    use :memoizer_methods
    use :output_adapters_quickie

    context '(context)' do

      it "the output adatper module loads" do
        output_adapter_module_
      end

      it "the document parser loads (which is the same as builds)" do
        output_adapter_test_document_parser_ || fail
      end

      it "the document parser can parse THIS SELFSAME FILE" do

        _omg = _omg_parse_tree_of_this_selfsame_file

        _act = TS_::Ersatz_Parser::Show_structure_into[ "", _omg.nodes ]

        # NOTE how we're allowing the structure of this selfsame
        # document to flex *somewhat* but only in the number of items:

        _rx = /\A
              module\n
              [ ][ ]describe\n
              [ ][ ][ ][ ]context_node\n
          (?: [ ][ ][ ][ ][ ][ ]example_node\n  ){3,}
        /x

        _rx =~ _act || fail
      end

      it "it is lossless (the document is nonmutated)" do

        fh = _open_file_two_times
        _EXPECTED_BIG_STRING = fh.read
        fh.close

        _node = _omg_parse_tree_of_this_selfsame_file

        _ACTUAL_BIG_STRING = _node.write_lines_into ""

        _ACTUAL_BIG_STRING == _EXPECTED_BIG_STRING or fail  # etc
      end

      shared_subject :_omg_parse_tree_of_this_selfsame_file do
        fh = _open_file_two_times
        x = output_adapter_test_document_parser_.parse_line_stream fh
        fh.close
        x
      end

      def _open_file_two_times
        ::File.open __FILE__
      end
    end
  end
end
# #history: rename-and-rewrite of will-rewrite first test file for this output adapter
