require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize - compond compound" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context "create (no existing test file)" do

      call_by do
        the_API_call_
      end

      shared_subject :_custom_tuple do
        __build_custom_tuple_samely
      end

      def the_existing_test_file_path_
        NIL  # NOTHING_
      end

      it "const def 1" do
        _class 'X_xkcd_Foo', _at( 0, 0 )
      end

      it "const def 2" do
        _class 'X_xkcd_Bar', _at( 1, 0 )
      end

      it "test 1" do
        _test "test one", "X_xkcd_Foo", _at( 0, 1 )
      end

      it "test 2" do
        _test "test two", "X_xkcd_Bar", _at( 1, 1 )
      end
    end

    def __build_custom_tuple_samely

      _st = root_ACS_result

      _doc = test_document_via_line_stream_ _st

      _desc = _doc.only_one :module, :describe

      a = _desc.immediates :context_node

      2 == a.length || fail
      ctx1, ctx2 = a
      a = filter_endcaps_and_blank_lines_common_ ctx1.nodes
      a_ = filter_endcaps_and_blank_lines_common_ ctx2.nodes
      [ a, a_ ]
    end

    def the_asset_file_path_
      fixture_file_ '25-compound-compound.kd'  # #coverpoint5-6
    end

    def _class s, nodes
      _exp = "        class #{ s }\n"
      nodes[1].line_string == _exp || fail
    end

    def _test dsc, const, nodes

      _exp = "      it \"#{ dsc }\" do\n"
      nodes[0].line_string == _exp || fail

      _exp = "        #{ const }."
      _act = nodes[1].line_string[ 0, _exp.length ]
      _act == _exp || fail
    end

    def _at d, d_
      _ctx = _custom_tuple.fetch d
      _ctx.fetch( d_ ).nodes
    end
  end
end
