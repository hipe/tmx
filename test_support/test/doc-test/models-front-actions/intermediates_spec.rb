require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - [ actions ] - intermediates" do

    extend TS_
    use :expect_event

    it "no path" do

      begin
        call_API :intermediates
      rescue ::ArgumentError => e
      end

      e.message.should eql "missing required property 'path'"
    end

    it "path must be absolute" do

      call_API :intermediates, :path, 'some/relpath'
      _em = expect_not_OK_event
      _sym = _em.cached_event_value.to_event.terminal_channel_symbol
      :path_cannot_be_relative == _sym or fail
      expect_failed
    end

    it "path not found" do

      call_API :intermediates, :path, a_path_for_a_file_that_does_not_exist
      expect_not_OK_event :stat_error
      expect_failed
    end

    it "path exists, has sibling TS file, dry run", wip: true do

      call_API :intermediates, :path, a_deep_path, :dry_run
      expect_neutral_event :writing
      expect_OK_event :wrote
      expect_neutral_event :writing
      expect_OK_event :wrote
      expect_OK_event :finished
      expect_succeeded
    end

    it "preview works", wip: true do

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
