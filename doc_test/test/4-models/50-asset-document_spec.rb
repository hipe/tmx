require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "models - asset document" do

    TS_[ self ]
    use :memoizer_methods
    use :fixture_files

    context "(essential)" do

      it "loads" do
        _subject_module
      end
    end

    context "(document one)" do

      shared_subject :_document do
        _ls = line_stream_via_fixture_file_symbol_ :one
        _subject_module.via_line_stream___ _ls
      end

      it "builds via line stream" do
        _document or fail
      end

      it "as-is, whole document is lossless" do

        TestSupport_::Expect_Line::Streams_have_same_content.call(
          _document.to_line_stream___,
          line_stream_via_fixture_file_symbol_( :one ),
          self,
        )
      end
    end

    def _subject_module
      models_module_::AssetDocument
    end
  end
end
