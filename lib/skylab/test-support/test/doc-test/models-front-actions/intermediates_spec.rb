require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - [ actions ] - intermediates" do

    TestLib_::Expect_event[ self ]

    extend TS_

    it "no path" do
      -> do
        call_API :intermediates
      end.should raise_error ::ArgumentError, "missing required property 'path'"
    end

    it "path must be absolute" do

      call_API :intermediates, :path, 'some/relpath'
      expect_not_OK_event :path_cannot_be_relative
      expect_failed

    end

    it "path not found" do

      call_API :intermediates, :path, a_path_for_a_file_that_does_not_exist
      expect_not_OK_event :errno_enoent
      expect_failed

    end

    it "path exists, has sibling TS file, dry run" do

      call_API :intermediates, :path, a_deep_path, :dry_run
      expect_neutral_event :writing
      expect_OK_event :wrote
      expect_neutral_event :writing
      expect_OK_event :wrote
      expect_OK_event :finished
      expect_succeeded

    end

    it "preview works" do

      io = build_IO_spy_downstream_for_doctest
      call_API :intermediates, :downstream, io, :preview, :path, a_deep_path
      expect_OK_event :wrote
      expect_OK_event :wrote
      expect_OK_event :finished
      expect_succeeded

    end

    def a_deep_path
      TS_.dir_pathname.join( 'models-front-actions/generate/integration/core_spec.rb' ).to_path
    end
  end
end
