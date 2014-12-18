require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - [ actions ] - generate" do

    TestLib_::Expect_event[ self ]

    TestSupport_::Expect_line[ self ]

    extend TS_

    it "for the output adapter indicate no name" do
      call_API_with :output_adapter, nil
      expect_not_OK_event :wrong_const_name
      expect_failed
    end

    it "for the output adapter indicate a strange name" do
      call_API_with :output_adapter, :wazoozle
      expect_not_OK_event :uninitialized_constant
      expect_failed
    end

    it "no line downstream" do
      call_API_with :output_adapter, :quickie
      expect_not_OK_event :no_downstream
      expect_failed
    end

    it "no line upstream" do
      call_API_with :output_adapter, :quickie, :line_downstream, :_HI_
      expect_not_OK_event :no_line_upstream
      expect_failed
    end

    it "noent" do
      _path = DocTest_.dir_pathname.join( 'no-such-file' ).to_path
      @down_IO = :_HI_
      call_API_against_path _path
      expect_not_OK_event :errno_enoent
      expect_failed
    end

    it "normal (partial integration) - spot check of content in a single context" do

      _path = DocTest_.dir_pathname.join( Callback_::Autoloader.default_core_file ).to_path
      call_API_against_path _path

      expect_neutral_event :wrote
      expect_no_more_events
      expect_neutral_result

      @output_s = @down_IO.string

      advance_to_module_line

      line.should eql "module Skylab::TestSupport::TestSupport::DocTest\n"

      @interesting_line_rx = /\A      (?!end\b)[^ ]/

      next_interesting_line_dedented.should eql "Sandbox_1 = Sandboxer.spawn\n"

      next_interesting_line_dedented.should eql "before :all do\n"

      next_interesting_line_dedented.should match %r(\Ait "this line here)

    end

    it "PRE-FINAL INTEGRATION HACK TEST (dry run)" do

      _upstream_path_OMG = DocTest_.dir_pathname.
        join( 'models-/front/actions/generate.rb' ).to_path

      _output_path_OMG = TestSupport_.dir_pathname.
        join( 'test/doc-test/models-front-actions/generate/integration/core_spec.rb' ).to_path

      @result = subject_API.call(
        :generate,
        :is_dry_run, true,  # FLIP THIS OFF to re-write the file!
        :output_path, _output_path_OMG,
        :upstream_path, _upstream_path_OMG,
        :output_adapter, :quickie,
        :on_event_selectively, handle_event_selectively )

      expect_neutral_event :before_editing_existing_file
      expect_neutral_event :wrote
      expect_no_more_events
      expect_neutral_result
    end

    def call_API_with * x_a
      x_a.unshift :generate
      call_API_via_iambic x_a
    end

    def call_API_against_path x
      @down_IO ||= TestSupport_::Library_::StringIO.new
      x_a = [
        :generate,
        :output_adapter, :quickie,
        :line_downstream, @down_IO ]
      x_a.push :upstream_path, x
      call_API_via_iambic x_a
    end
  end
end
