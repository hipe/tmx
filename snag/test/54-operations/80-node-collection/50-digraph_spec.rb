require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - node collection - digraph" do

    TS_[ self ]
    use :expect_event

    it "if no focus nodes in upstream, produces empty digraph with message" do

      y = []
      call_API :node_collection, :digraph,
        :byte_downstream, y,
        :upstream_identifier, Fixture_file_[ :rochambeaux_mani ]

      expect_neutral_event :info,
        "none of the 3 nodes in the collection are doc nodes."

      y.length.should eql 3  # digraph open, thing ding, digraph close

      @result.should eql true
    end

    it "the focused subset of the dependency graph is shown. escapes 2 things" do

      lines = [] # (for debugging, assign this variable instead to stderr)

      call_API :node_collection, :digraph,
        :byte_downstream, lines,
        :upstream_identifier, Fixture_file_[ :for_digraph_simple_mani ]

      __expect_these_line lines
    end

    def __expect_these_line lines

      st = Common_::Stream.via_nonsparse_array lines

      st.gets.should eql "digraph {\n"
      st.gets[ 0, 8 ].should eql '  node ['

      s = st.gets
      s.chop!
      s.should eql '  5 [label="i said\n\"hi\"\n[#005]"]'

      s = st.gets
      s.chop!
      s.should eql '  4 [label="some\ntopic\na-\>b\n[#004]"]'

      st.gets.should eql "  5->4\n"
      st.gets.should eql "}\n"
      st.gets.should be_nil

      expect_succeeded
    end
  end
end
