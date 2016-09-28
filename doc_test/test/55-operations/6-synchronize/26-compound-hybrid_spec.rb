require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - compound hybrid" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context "combo platter" do

      call_by do

        _asset = fixture_file_ '16-combo-platter.kd'

        # _test = fixture_file_ '56-sync-against-this_speg.kd'

        my_API_common_generate_(
          asset_line_stream: ::File.open( _asset ),
          # original_test_line_stream: ::File.open( _test ),
          # original_test_path: 'foobie/doobie/test/anthony-banthony/canthony-danthony_nosee.zz',
        )
      end

      shared_subject :_custom_tuple do
        n_significant_nodes_from_only_context_node_via_result_ 4
      end

      it "looks OK structurally" do
        _custom_tuple || fail
      end

      it "the const def is interpolated" do
        _ = _custom_tuple.fetch 0
        _.nodes[1].line_string == "        class X_xkcd_Baz\n" || fail
      end

      it "last example is interpolated" do
        _ = _custom_tuple.fetch 3
        _.nodes[1].line_string == "        otr = X_xkcd_Baz.new\n" || fail
      end

      it "the shared subject is interpolated" do
        _ = _custom_tuple.fetch 1
        _.nodes[1].line_string == "        X_xkcd_Baz.new\n" || fail
      end
    end
  end
end
