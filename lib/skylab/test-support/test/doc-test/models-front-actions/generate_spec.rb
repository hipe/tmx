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
      @down_IO = :_HI_
      call_API_against_path a_path_for_a_file_that_does_not_exist
      expect_not_OK_event :errno_enoent
      expect_failed
    end

    it "nothing specy in the file"

    it "normal (partial integration) - spot check of content in a single context" do

      _path = DocTest_.dir_pathname.join( Callback_::Autoloader.default_core_file ).to_path
      call_API_against_path _path

      expect_neutral_event :current_output_path
      expect_neutral_event :wrote
      expect_no_more_events
      expect_neutral_result

      @output_s = @down_IO.string

      advance_to_module_line

      line.should eql "module Skylab::TestSupport::TestSupport::DocTest\n"

      @interesting_line_rx = /\A      (?!end\b)[^ ]/

      next_interesting_line_dedented.should eql "before :all do\n"

      next_interesting_line_dedented.should match %r(\Ait "this line here)

    end

    it "`force` argument works" do

      call_API :generate,
        :output_path, common_real_life_output_path,
        :output_adapter, :quickie

      ev = expect_not_OK_event :missing_required_permission

      black_and_white( ev ).should match %r(\A'path' exists, won't overwrite #{
        }without 'force': «[^»]+/integration/core_spec\.rb»\z)

      expect_failed

    end

    it "PRE-FINAL INTEGRATION HACK TEST (dry run)" do

      @result = subject_API.call(
        :generate,
        :dry_run,  # comment this out to re-write the file!
        :force,
        :output_path, common_real_life_output_path,
        :upstream_path, common_upstream_path,
        :output_adapter, :quickie,
        :on_event_selectively, handle_event_selectively )

      expect_neutral_event :before_editing_existing_file
      expect_neutral_event :wrote
      expect_no_more_events
      expect_neutral_result
    end

    def common_upstream_path
      DocTest_.dir_pathname.join( 'models-/front/actions/generate/core.rb' ).to_path
    end

    def common_real_life_output_path
      TestSupport_.dir_pathname.join(
        'test/doc-test/models-front-actions/generate/integration/core_spec.rb'
      ).to_path
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
