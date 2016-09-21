require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize - compound update" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context 'syncing with compounds is tricky - ' do

      call_by do

        _asset = ::File.join home_dir_path_, 'models-/test-file-context.rb'
        _asset_lines = ::File.open _asset

        _test = path_via_filename_ '56-sync-against-this_speg.kd'
        _test_lines = ::File.open _test

        my_API_common_generate_(
          asset_line_stream: _asset_lines,
          original_test_line_stream: _test_lines,
          original_test_path: 'foobie/doobie/test/anthony-banthony/canthony-danthony_nosee.zz',
        )
      end

      shared_subject :_custom_tuple do

        _st = root_ACS_result

        _doc = Home_::OutputAdapters_::Quickie::Models::TestDocument.via_line_stream _st

        _ctxt = _doc.only_one :module, :describe, :context

        a = _ctxt.nodes

        :blank_line == a[1].category_symbol || fail
        before = a[2]
        :blank_line == a[3].category_symbol || fail
        6 == a.length || fail
        [ before, a[4] ]
      end

      it "looks OK structurally" do
        _custom_tuple || fail
      end

      it "the before block got updated" do
        a = _custom_tuple.first.nodes
        a[1].line_string == "        X_ab_cd_PATH = \"test/1-abc-def/ghi-jkl_speg.kode\"\n" || fail
        3 == a.length || fail
      end

      it "the example block looks right" do
        a = _custom_tuple.last.nodes
        a[1].line_string == "        o = Home_::Models_::TestFileContext.via_path X_ab_cd_PATH\n" || fail
        a[2].line_string == "        o.short_hopefully_unique_stem.should eql \"ad_gj\"\n" || fail
        4 == a.length || fail
      end
    end
  end
end
