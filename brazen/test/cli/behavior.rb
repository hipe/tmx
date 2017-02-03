module Skylab::Brazen::TestSupport

  module CLI::Behavior

    # detailed expectation methods for how a [br] CLI expresses itself

    # sections fugue with those in "CLI expectations"

    # (note we are transitioning between paradigms - ..)

    class << self

      def [] tcc

        TS_.lib_( :CLI_support_expectations )[ tcc ]

        tcc.extend Module_Methods___

        tcc.include self

        NIL_
      end
    end  # >>

    module Module_Methods___

      def with_invocation * s_a

        o = -> m, & p do
          TestSupport_::Define_dangerous_memoizer.call self, m, & p
        end

        o.call :localized_invite_line_rx do

          _s_a_ = _deep_strings

          /\Ause '?#{ _s_a_ * SPACE_ } -h'? for help\z/
        end

        o.call :_invocation_string do
          _deep_strings.join( SPACE_ ).freeze
        end

        o.call :_deep_strings do

          s_a_ = invocation_strings_for_expect_stdout_stderr.dup
          a = argv_prefix_for_expect_stdout_stderr
          if a
            s_a_.concat a
          end
          s_a_.freeze
        end

        send :define_method, :argv_prefix_for_expect_stdout_stderr do

          # #ts-029]#hook-in:1

          s_a
        end

        NIL_
      end
    end

    def subject_CLI  # ..
      Home_::Command_Line_Client
    end

    # -- the general shape of invocation (exitstatus, which streams)

    def expect_errored_with sym
      expect_no_more_lines
      expect_exitstatus_for sym
    end

    def results_in_error_exitstatus_
      state_.exitstatus.should match_common_error_code_
    end

    def expect_exitstatus_for sym
      @exitstatus.should eql Home_::API.exit_statii.fetch sym
    end

    def expect_errored
      expect_no_more_lines
      expect_generic_error_exitstatus
    end

    def expect_generic_error_exitstatus
      @exitstatus.should match_common_error_code_
    end

    def match_common_error_code_
      eql result_for_failure_for_expect_stdout_stderr
    end

    def expect_succeed
      expect_no_more_lines
      @exitstatus.should match_successful_exitstatus
    end

    def results_in_success_exitstatus_
      state_.exitstatus.should match_successful_exitstatus
    end

    def match_common_informational_stream_set_
      eql STDERR_STREAM_ONLY___
    end

    STDERR_STREAM_ONLY___ = [ :e ]

    # -- macros (predicates over several lines) (we don't want these)

# ________BEGIN: these need improvement somehow

    def expect_branch_expression_pattern_zero__
      expect_expecting_action_line
      expect_branch_usage_line_
      expect_action_invite_line_
      expect_errored
    end

    def expect_branch_expression_pattern_one_dot_one__
      expect_unrecognized_action :fiffle
      expect_stdout_stderr_via known_actions_are_
      expect_action_invite_line_
      expect_errored
    end

    def known_actions_are_

      _s_a = expected_action_name_string_array_.map do | s |
        "'?#{ ::Regexp.escape s }'?"
      end

      _rx = /\Aknown actions are \(#{ _s_a.join ', ' }\)\z/

      expectation :styled, _rx
    end

    def expect_branch_expression_pattern_one_dot_two__

      expect_stdout_stderr_via invalid_option '-x'
      expect_action_invite_line_
      expect_errored
    end

# ________END

    # -- invalid / unexpected / expecting (none)

    # -- usage (syntax summaries, suggestions)

    def expect_branch_usage_line_

      expect_stdout_stderr_via branch_usage_line_
    end

    def branch_usage_line_

      expectation :styled, "usage: #{ _invocation_string } <action> [..]"
    end

    def branch_secondary_syntax_line_

      expectation "#{ SPACE_ * 7 }#{ _invocation_string } -h [cmd]"
    end

    def _expect_action_usage_line

      expect_stdout_stderr_via action_usage_line_
    end

    def action_usage_line_

      expectation :styled, "usage: #{ _invocation_string }#{ usage_syntax_tail_ }"
    end

    # -- invitations

    def expect_branch_invite_line_

      expect_stdout_stderr_via branch_invite_line_
    end

    def branch_invite_line_

      _s = "use '#{ _invocation_string } -h <action>' for help on that action."
      expectation :styled, _s
    end

    def expect_action_invite_line_

      expect_stdout_stderr_via action_invite_line_
    end

    def action_invite_line_

      styled_invite_to _invocation_string
    end

    # -- bridge to line-by-line assertion

    def on_body_lines_from_help_screen_section_ s

      st = _normal_emission_stream_via_section s

      st.gets  # discard the header line (typically)

      _receive_normal_emissions_stream_intended_to_be_used_as_upstream st
    end

    def on_lines_from_help_screen_section_ s

      _st = _normal_emission_stream_via_section s

      _receive_normal_emissions_stream_intended_to_be_used_as_upstream _st
    end

    def _normal_emission_stream_via_section s

      _state = state_

      _t = _state.lookup s

      _st = _t.to_emission_stream

      _st
    end

    def _receive_normal_emissions_stream_intended_to_be_used_as_upstream st

      _st_ = st.flush_to_scanner

      self.stream_for_expect_stdout_stderr = _st_

      NIL_
    end
  end
end
