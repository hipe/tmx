module Skylab::Brazen::TestSupport

  module CLI::Behavior

    # detailed expectation methods for how a [br] CLI expresses itself

    class << self

      def [] tcc

        TS_.lib_( :CLI_expectations )[ tcc ]

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
          s_a_.concat argv_prefix_for_expect_stdout_stderr
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
      Home_::CLI::Client_for_Brazen_as_Application
    end

    # ~ common business assertions

    def expect_branch_pattern_zero
      expect_expecting_action_line
      expect_branch_usage_line
      expect_action_invite_line
      expect_errored
    end

    def expect_branch_pattern_one_one
      expect_unrecognized_action :fiffle
      _rx = ___build_known_actions_rx
      expect :styled, _rx
      expect_action_invite_line
      expect_errored
    end

    def ___build_known_actions_rx
      /\Aknown actions are \(#{ self.class::EXPECTED_ACTION_NAME_S_A.
        map { |s| "'?#{ ::Regexp.escape s }'?" } * ', ' }\)\z/
    end

    def expect_branch_pattern_one_two
      expect 'invalid option: -x'
      expect_action_invite_line
      expect_errored
    end

    def expect_expecting_action_line
      expect :styled, 'expecting <action>'
    end

    def expect_branch_help_screen_first_half__

      expect_branch_usage_line
      expect_branch_secondary_syntax_line
      expect_maybe_a_blank_line

      expect_description_line
      expect_maybe_a_blank_line
    end

    def expect_branch_help_screen_second_half__

      expect_header_line 'actions'
      expect_these_actions
      expect_maybe_a_blank_line

      expect_branch_invite_line
      expect_succeeded
    end

    def expect_action_help_screen
      expect_action_usage_lines
      expect_description
      expect_options
      expect_arguments
      expect_environment_variables
      expect_succeeded
    end

    def expect_action_usage_lines
      expect_action_usage_line
      expect "#{ ' ' * 7 }#{ _invocation_string } -h"
      expect_maybe_a_blank_line
    end

    def expect_action_usage_line
      expect :styled, "usage: #{ _invocation_string }#{ prop_syntax }"
    end

    def expect_description
      expect :styled, "description: #{ description_body_copy }"
      expect_maybe_a_blank_line
    end

    def expect_options
      expect_header_line 'options'
      expect_these_options
      expect_maybe_a_blank_line
    end

    def expect_arguments
      expect :styled, %r(\Aarguments?\z)  # no colon because [#072]
      expect_these_arguments
      expect_maybe_a_blank_line
    end

    def expect_environment_variables
    end

    def expect_branch_usage_line
      expect :styled, "usage: #{ _invocation_string } <action> [..]"
    end

    def expect_branch_secondary_syntax_line
      expect "#{ ' ' * 7 }#{ _invocation_string } -h [cmd]"
    end

    def expect_help_screen_for_init

      expect :styled, 'usage: xaz init [-d] [-v] <path>'
      expect %r(\A[ ]{7}xaz init -h\z)
      expect_maybe_a_blank_line
      expect_header_line 'description'
      expect :styled, 'init a <workspace>'
      expect 'this is the second line of the init description'
      expect_maybe_a_blank_line
      expect_header_line 'options'
      expect %r(\A[ ]{4}-d, --dry-run\z)
      expect %r(\A[ ]{4}-v, --verbose\z)
      expect %r(\A[ ]{4}-h, --help[ ]{10,}this screen\z)
      expect_maybe_a_blank_line
      expect_header_line 'argument'
      expect %r(\A[ ]{4}path[ ]{7,}the dir)
      expect_succeeded
    end

    def status_prop_syntax
      ' [-v] [<path>]'
    end

    def expect_branch_auxiliary_usage_line
      expect "#{ ' ' * 7 }#{ _invocation_string } -h [cmd]"
    end

    def expect_branch_invite_line
      expect :styled, "use '#{ _invocation_string } -h <action>' for help on that action."
    end

    def expect_action_invite_line
      expect :styled, "use '#{ _invocation_string } -h' for help"
    end

    def expect_errored_with i
      expect_no_more_lines
      expect_exitstatus_for i
    end

    def expect_exitstatus_for i
      @exitstatus.should eql Home_::API.exit_statii.fetch i
    end

    def expect_errored
      expect_no_more_lines
      expect_generic_error_exitstatus
    end

    def expect_generic_error_exitstatus
      @exitstatus.should eql Home_::CLI::GENERIC_ERROR_EXITSTATUS
    end

    def expect_succeeded
      expect_no_more_lines
      @exitstatus.should eql Home_::CLI::SUCCESS_EXITSTATUS
    end

    def expect_option i, rx=nil
      if rx
        _xtra_rxs = "[ ]{10,}.*#{ rx.source }.*"
      end
      s = i.to_s
      expect %r(\A[ ]{4,}-#{ s[0] }, --#{ s }#{ _xtra_rxs }\z)
    end

    def expect_item i, * x_a
      a = []
      :styled == x_a.first and a.push x_a.shift
      rx = x_a.shift
      if rx
        _xtra_rxs = ".*#{ rx.source }.*"
      end
      s = i.to_s
      a.push %r(\A[ ]{4,}#{ ::Regexp.escape s }[ ]{10,}#{ _xtra_rxs }\z)
      expect( * a )
      while x_a.length.nonzero?
        d = x_a.length
        a.clear
        :styled == x_a.first and a.push x_a.shift
        rx = x_a.first
        if rx
          x_a.shift
          a.push %r(\A[ ]{15,}.*#{ rx.source }.*\z)
        end
        d == x_a.length and raise ::ArgumentError, "#{ x_a.first.inspect }"
        expect( * a )
      end
    end
  end
end
