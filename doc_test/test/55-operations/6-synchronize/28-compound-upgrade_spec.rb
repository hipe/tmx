require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - compound upgrade" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context "(context)" do  # #coverpoint5-4

      call_by do

        _asset = fixture_file_ '17-upgrade.kd'

        _test = fixture_file_ '51-some_speg.rb'

        my_API_common_generate_(
          asset_line_stream: ::File.open( _asset ),
          original_test_line_stream: ::File.open( _test ),
        )
      end

      shared_subject :_custom_tuple do
        n_significant_nodes_from_only_context_node_via_result_ 3
      end

      it "looks OK structurally" do
        _custom_tuple || fail
      end

      it "the const def came through" do
        o = _custom_tuple.fetch 0
        o.category_symbol == :before || fail
        o.nodes[1].line_string == "        X_xkcd_Foo = :hi\n" || fail
      end

      it "first test" do
        o = _custom_tuple.fetch 1
        o.category_symbol == :example_node || fail
        o.nodes[1].line_string == "        expect( 1 ).to eql 1\n" || fail
      end

      it "second test" do
        o = _custom_tuple.fetch 2
        o.category_symbol == :example_node || fail
        o.nodes[1].line_string == "        expect( 2 ).to eql 2\n" || fail
      end
    end
  end
end
