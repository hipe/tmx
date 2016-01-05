require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - [ actions ] - generate" do

    extend TS_
    use :memoizer_methods
    use :expect_event
    use :expect_line

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
      expect_not_OK_event :no_upstream
      expect_failed
    end

    it "noent" do
      @down_IO = :_HI_
      call_API_against_path a_path_for_a_file_that_does_not_exist
      expect_not_OK_event :stat_error
      expect_failed
    end

    it "nothing specy in the file"

    context "(worky)" do

      shared_subject :_state do

        _path = ::File.join(
          DocTest_.dir_pathname.to_path,
          Callback_::Autoloader.default_core_file )

        call_API_against_path _path

        DT_Models_Gen_Struct = ::Struct.new(
          :emission_array,
          :output_string,
          :result )

        DT_Models_Gen_Struct.new(
          @event_log.flush_to_array,
          @down_IO.string,
          @result,
        )
      end

      it "neutral event talkin bout current output path (none)" do

        @event_log = Callback_::Stream.via_nonsparse_array _state.emission_array

        expect_neutral_event :current_output_path do | we |
          we.to_event.path and fail
        end

        expect_no_more_events
      end

      it "result is an emission talking about wrote - knows if dry" do

        _state.result.category.should eql [ :success, :wrote ]
        _wrote.is_known_to_be_dry and fail
      end

      it "wrote has line count" do

        ( 20 .. 40 ).should be_include _wrote.line_count
      end

      it "knows if dry run" do

        ( 900 .. 1100 ).should be_include _wrote.bytes
      end

      dangerous_memoize :_wrote do
        _state.result.emission_value_proc.call
      end

      it "content looks OK" do

        @output_s = _state.output_string

        advance_to_module_line

        line.should eql "module Skylab::TestSupport::TestSupport::DocTest\n"

        @interesting_line_rx = /\A      (?!end\b)[^ ]/

        next_interesting_line_dedented.should eql "before :all do\n"

        next_interesting_line_dedented.should match %r(\Ait "this line here)
      end
    end

    it "`force` argument works" do

      call_API :generate,
        :output_path, _common_real_life_output_path,
        :output_adapter, :quickie

      _em = expect_not_OK_event :missing_required_properties

      black_and_white( _em.cached_event_value ).should match(
        %r(\A'path' exists, won't overwrite #{
          }without 'force': «[^»]+/integration/core_spec\.rb»\z) )

      expect_failed
    end

    it "PRE-FINAL INTEGRATION HACK TEST (dry run)" do

      em = subject_API.call(
        :generate,
        :dry_run,  # comment this out to re-write the file!
        :force,
        :output_path, _common_real_life_output_path,
        :upstream_path, common_upstream_path,
        :output_adapter, :quickie,
        :on_event_selectively, event_log.handle_event_selectively )

      expect_neutral_event :before_editing_existing_file
      wrote  = em.emission_value_proc[]

      wrote.is_known_to_be_dry or fail
      ( 1300..1500 ).should be_include wrote.bytes
      ( 37..57 ).should be_include wrote.line_count
    end

    def common_upstream_path
      DocTest_.dir_pathname.join( 'models-/front/actions/generate/core.rb' ).to_path
    end

    def _common_real_life_output_path

      Top_TS_.test_path_(
        'doc-test/models-front-actions/generate/integration/core_spec.rb' )
    end

    def call_API_with * x_a
      x_a.unshift :generate
      call_API_via_iambic x_a
    end

    def call_API_against_path x
      @down_IO ||= Home_::Library_::StringIO.new
      x_a = [
        :generate,
        :output_adapter, :quickie,
        :line_downstream, @down_IO ]
      x_a.push :upstream_path, x
      call_API_via_iambic x_a
    end
  end
end
