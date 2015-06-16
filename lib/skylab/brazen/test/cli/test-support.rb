require_relative '../test-support'

module Skylab::Brazen::TestSupport::CLI

  ::Skylab::Brazen::TestSupport[ TS_ = self ]

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  module ModuleMethods

    def fake_app_name
      FAKE_APP_NAME__
    end

    def with_invocation * _S_A_

      _S_A_.freeze
      define_method :argv_prefix_for_expect_stdout_stderr do _S_A_ end

      _RX_ = /\Ause '?bzn #{ _S_A_ * SPACE_ } -h'? for help\z/
      define_method :localized_invite_line_rx do _RX_ end

      _S_ = ( [ fake_app_name, * _S_A_ ] * SPACE_ ).freeze
      define_method :invocation_string do _S_ end
    end
  end

  module InstanceMethods

    include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods

    define_method :expect, instance_method( :expect )  # because rspec

    # #todo - a lot of this is redundant with `expect-CLI`

    # ~ invoke phase ("action under test")

    def invoke * argv
      using_expect_stdout_stderr_invoke_via_argv argv
    end

    def subject_CLI  # for above
      Brazen_::CLI::Client_for_Brazen_as_Application
    end

    def invocation_strings_for_expect_stdout_stderr
      FAKE_INVO_STRING_ARY___
    end

    # ~ common business assertions

    def expect_branch_pattern_zero
      expect_expecting_action_line
      expect_branch_usage_line
      expect_action_invite_line
      expect_errored
    end

    def expect_branch_pattern_one_one
      expect :styled, /\Aunrecognized action ['"]?fiffle['"]?\z/
      _rx = bld_known_actions_rx
      expect :styled, _rx
      expect_action_invite_line
      expect_errored
    end

    def bld_known_actions_rx
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

    def expect_branch_help_screen_first_half
      expect_branch_usage_line
      expect_branch_secondary_syntax_line
      expect_maybe_a_blank_line

      expect_description_line
      expect_maybe_a_blank_line
    end

    def expect_branch_help_screen_second_half
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
      expect "#{ ' ' * 7 }#{ invocation_string } -h"
      expect_maybe_a_blank_line
    end

    def expect_action_usage_line
      expect :styled, "usage: #{ invocation_string }#{ prop_syntax }"
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
      expect :styled, "usage: #{ invocation_string } <action> [..]"
    end

    def expect_branch_secondary_syntax_line
      expect "#{ ' ' * 7 }#{ invocation_string } -h [cmd]"
    end

    def expect_help_screen_for_init

      expect :styled, 'usage: bzn init [-d] [-v] <path>'
      expect %r(\A[ ]{7}bzn init -h\z)
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
      expect "#{ ' ' * 7 }#{ invocation_string } -h [cmd]"
    end

    def expect_branch_invite_line
      expect :styled, "use '#{ invocation_string } -h <action>' for help on that action."
    end

    def expect_action_invite_line
      expect :styled, "use '#{ invocation_string } -h' for help"
    end

    def invocation_string
      self.class.fake_app_name
    end

    def expect_errored_with i
      expect_no_more_lines
      expect_exitstatus_for i
    end

    def expect_exitstatus_for i
      @exitstatus.should eql Brazen_::API.exit_statii.fetch i
    end

    def expect_errored
      expect_no_more_lines
      expect_generic_error_exitstatus
    end

    def expect_generic_error_exitstatus
      @exitstatus.should eql Brazen_::CLI::GENERIC_ERROR_
    end

    def expect_succeeded
      expect_no_more_lines
      @exitstatus.should eql Brazen_::CLI::SUCCESS_
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

  FAKE_APP_NAME__ = 'bzn'.freeze

  FAKE_INVO_STRING_ARY___ = [ FAKE_APP_NAME__ ].freeze

  Brazen_ = ::Skylab::Brazen
  Callback_ = Brazen_::Callback_
  SPACE_ = Brazen_::SPACE_

  module Constants
    Brazen_ = Brazen_
    TestSupport_ = TestSupport_
  end
end
