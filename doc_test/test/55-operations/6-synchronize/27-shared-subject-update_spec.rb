require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize - shared subject update" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context '(context)' do

      call_by do

        _asset = fixture_file_ '12-shared-subject.kd'
        _asset_lines = ::File.open _asset

        _test = fixture_file_ '62-shared-subj-tezd.kd'  # #coverpoint5-5
        _test_lines = ::File.open _test

        my_API_common_generate_(
          asset_line_stream: _asset_lines,
          original_test_line_stream: _test_lines,
        )
      end

      shared_subject :_custom_tuple do

        _ctxt = context_node_via_result_

        a = _ctxt.nodes
        a = filter_endcaps_and_blank_lines_common_ a
        3 == a.length || fail
        a
      end

      it "looks OK structurally" do
        _custom_tuple || fail
      end

      it "the before block got updated" do
        a = _custom_tuple.first.nodes
        a[1].line_string == "        X_xkcd_MyPerkser = K::D::Lang.new :foo, :baz\n" || fail
        3 == a.length || fail
      end

      it "the shared subject got updated" do
        a = _custom_tuple[1].nodes
        a[1].line_string == "        pxy = X_xkcd_MyPerkser.new(\n" || fail
      end

      it "the example block got updated" do
        a = _custom_tuple.last.nodes
        a[1].line_string == "        pxy.class.should eql X_xkcd_MyPerkser\n" || fail
        3 == a.length || fail
      end
    end
  end
end
