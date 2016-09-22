require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize - compound create" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context 'shoopilie doopilie' do

      call_by do

        _asset = fixture_file_ '11-before-all.kd'
        _asset_lines = ::File.open _asset

        my_API_common_generate_(
          asset_line_stream: _asset_lines,
        )
      end

      shared_subject :_custom_tuple do

        _ctxt = context_node_via_result_

        a = _ctxt.nodes

        :blank_line == a[1].category_symbol || fail
        before = a[2]
        :blank_line == a[3].category_symbol || fail
        6 == a.length || fail
        [ before, a[4] ]
      end

      it "looks OK structurally (level 0)" do
        _custom_tuple || fail
      end

      shared_subject :_this_tuple do

        # strange that the parsing of modules (classes) is not recursive

        _before_all = _custom_tuple.first
        a = _before_all.nodes[1].nodes

        [ a[0].line_string,
          a[1].line_string,
        ]
      end

      it "the structure of the before all is as expected (strange)" do
        _this_tuple || fail
      end

      it "outermost module etc" do
        _this_tuple[0] == "        module X_xkcd_MyApp\n" || fail
      end

      it "doesn't alter nested modules" do
        _this_tuple[1] == "          class MyClient\n" || fail
      end

      it "the example block looks right" do
        a = _custom_tuple.last.nodes

        a[1].nodes.first.line_string == "        module X_xkcd_MyApp\n" || fail
        a[1].nodes[1].line_string == "          def MyClient.xx\n" || fail
        a[-2].line_string == "        cli.xx.should eql :yy\n" || fail
        a.length == 6 || fail
      end
    end
  end
end
