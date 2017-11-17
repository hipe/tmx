require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] models - asset document" do

    TS_[ self ]
    use :memoizer_methods
    use :fixture_files

    context "(essential)" do

      it "loads" do
        _subject_module
      end
    end

    same = '01-one.kode'

    context "(document one)" do

      shared_subject :_document do
        _ls = line_stream_via_filename_ same
        _subject_module.via_line_stream___ _ls
      end

      it "builds via line stream" do
        _document or fail
      end

      it "as-is, whole document is lossless" do

        want_actual_line_stream_has_same_content_as_expected_(
          _document.to_line_stream___,
          line_stream_via_filename_( same ),
        )
      end
    end

    def _subject_module
      models_module_::AssetDocument
    end
  end
end
