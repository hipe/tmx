require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI canon level 1" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_behavior

    # it "  0)  no arguments"

    # it "1.1)  strange argument"

    with_invocation 'status'

    context "1.2)  strange option - ( E I )" do

      shared_subject :state_ do
        line_oriented_state_from_invoke '-z'
      end

      it "fails" do
        results_in_error_exitstatus_
      end

      it "all lines should be emitted on the correct stream" do
        expect( state_.stream_set ).to match_common_informational_stream_set_
      end

      it "first line talks about invalid option: -z" do
        expect( first_line ).to match_ invalid_option '-z'
      end

      it "last line talks about invite for help on that action" do
        expect( last_line ).to match_ action_invite_line_
      end

      it "there should be no other lines" do
        expect( state_.number_of_lines ).to eql 2
      end
    end

    # it "1.3)  good argument"

    context "1.4)  good option (help) gives you action help screen" do

      shared_subject :state_ do
        invoke '-h'
        flush_invocation_to_help_screen_oriented_state
      end

      it "succeeds" do
        results_in_success_exitstatus_
      end

      it "all lines should be emitted on the correct stream" do
        expect( state_.stream_set ).to match_common_informational_stream_set_
      end

      it "description section is `tight`" do

        on_lines_from_help_screen_section_ 'description'

        want :styled, %r(\Adescription: .+\bstatus\b)

        want_no_more_lines  # (because how trees are parsed)
        # want_maybe_a_blank_line (would work too)
      end

      it "option section has verbose option and help option" do

        on_body_lines_from_help_screen_section_ 'options'
        want_option :verbose
        want_option :help, %r(this screen)
      end

      it "arguments section is `singular`, has `path` item" do

        on_body_lines_from_help_screen_section_ 'argument'
        want_item :path, %r(\blocation\b.+), :styled, %r(\bneat\b)
      end

      it "environemnt variables section oh my" do

        on_body_lines_from_help_screen_section_ 'environment variable'
        want_item :BRAZEN_MAX_NUM_DIRS, %r(\bhow far\b)
      end
    end

    context "2)    extra argument - ( E U I )" do

      shared_subject :state_ do
        line_oriented_state_from_invoke 'wing', 'wang'
      end

      it "fails" do
        results_in_error_exitstatus_
      end

      it "first line talking bout unexpected" do
        expect( first_line ).to match_ unexpected_argument 'wang'
      end

      it "last line invites" do
        expect( last_line ).to match_ action_invite_line_
      end

      it "middle line is usage" do
        expect( second_line ).to match_ action_usage_line_
      end
    end

    def usage_syntax_tail_
      ' [-v] [<path>]'
    end
  end
end
