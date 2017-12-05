require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - compound upgrade again" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context "(context)" do  # #coverpoint5.4B

      call_by do

        _asset = fixture_file_ '18-upgrade-again.kd'

        _test = fixture_file_ '68-upgrade-again-tezd.kd'

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

      it "the shared subject through" do
        o = _custom_tuple.fetch 0
        o.category_symbol == :shared_subject || fail
        a = o.nodes
        a[0].line_string == "      shared_subject :p do\n" || fail
        a[1].line_string == "        some thing\n" || fail
        a[2].line_string == "      end\n" || fail
      end

      it "first test came thru" do
        o = _custom_tuple.fetch 1
        o.category_symbol == :example_node || fail
        o.nodes[1].line_string == "        expect( p[ [ 'abc' ] ] ).to eql nil\n" || fail
      end

      it "third test casme through" do
        o = _custom_tuple.fetch 2
        o.category_symbol == :example_node || fail
        o.nodes[1].line_string == "        expect( 1 ).to eql 2\n"
      end
    end
  end
end
