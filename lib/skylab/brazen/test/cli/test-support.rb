require_relative '../test-support'

module Skylab::Brazen::TestSupport::CLI

  ::Skylab::Brazen::TestSupport[ TS_ = self ]

  Brazen_ = ::Skylab::Brazen
  Callback_ = Brazen_::Callback_
  TestSupport_ = ::Skylab::TestSupport

  SPACE_ = Brazen_::SPACE_

  module Constants
    Brazen_ = Brazen_
    TestSupport_ = TestSupport_
  end

  extend TestSupport_::Quickie

  module ModuleMethods

    def fake_app_name
      FAKE_APP_NAME__
    end
    FAKE_APP_NAME__ = 'bzn'.freeze

    def with_invocation * _S_A_

      _S_A_.freeze
      define_method :sub_action_s_a do _S_A_ end

      _RX_ = /\Ause '?bzn #{ _S_A_ * SPACE_ } -h'? for help\z/
      define_method :localized_invite_line_rx do _RX_ end

      _S_ = ( [ fake_app_name, * _S_A_ ] * SPACE_ ).freeze
      define_method :invocation_string do _S_ end
    end
  end

  module InstanceMethods

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
      expect :styled, %r(\Aarguments?:\z)
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
      expect :styled, 'usage: bzn init [-d] [-v] [<path>]'
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

    # ~ action-under-test phase

    def invoke * argv
      a = sub_action_s_a and argv[ 0, 0 ] = a
      invoke_via_argv argv
    end

    def invoke_with_no_prefix * argv
      invoke_via_argv argv
    end

    def invoke_via_argv argv
      grp = TestSupport_::IO.spy.group.new
      grp.do_debug_proc = -> { do_debug }
      grp.debug_IO = debug_IO
      grp.add_stream :i, :_no_instream_
      grp.add_stream :o
      grp.add_stream :e
      @IO_spy_group = grp
      @invocation = Brazen_::CLI.new nil, * grp.values_at( :o, :e ), [ 'bzn' ]
      prepare_invocation
      @exitstatus = @invocation.invoke argv ; nil
    end

    def prepare_invocation
    end

    # ~ assertion phase

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

    def expect * x_a
      load_expect_the_first_time
      expect_via_arg_list x_a
    end

    def load_expect_the_first_time  # ghastly hack that lets us regress
      cls = self.class
      # cls.include Callback_::Actor.methodic_lib.iambic_processing_instance_methods
      cls.send :define_method, :expect do |*x_a|
        expect_via_arg_list x_a
      end ; nil
    end

    def expect_no_more_lines
      if @act_stream.unparsed_exists
        fail "expected no more lines, had #{ @act_stream.current_token.to_a.inspect }"
      end
    end

    def expect_maybe_a_blank_line
      if @act_stream.unparsed_exists and NEWLINE__ == @act_stream.current_token.string
        @act_stream.advance_one
      end
    end

    NEWLINE__ = "\n".freeze

    def expect_header_line s
      expect :styled, "#{ s }:"
    end

    def expect_via_arg_list x_a
      prs_expectation x_a
      init_actual_stream
      @act_stream.unparsed_exists or fail "expected more lines, had none."
      @emission = @act_stream.gets_one
      @line_s = @emission.string
      @style_is_expected and assrt_styled_and_unstyle
      @line_s.chomp!
      send @line_assertion_method_i ; nil
    end

    def assrt_styled_and_unstyle
      line_s = @line_s.dup.gsub! SIMPLE_STYLE_RX__, EMPTY_STRING__
      line_s or fail "expected styled, was not: #{ @line_s }"
      @line_s = line_s ; nil
    end

    SIMPLE_STYLE_RX__ = /\e  \[  \d+  (?: ; \d+ )*  m  /x  # copy-paste [hl]
    EMPTY_STRING__ = ''.freeze

    def assrt_expected_line_equals_actual_line
      @line_s.should eql @line_assertion_x
    end

    def assrt_expected_rx_matches_actual_line
      @line_s.should match @line_assertion_x
    end

    def prs_expectation x_a
      init_expectation_stream x_a
      st = @exp_stream
      if :styled == st.current_token
        @style_is_expected = true
        st.advance_one
      else
        @style_is_expected = false
      end
      x = st.gets_one
      @line_assertion_x = x
      if x.respond_to? :ascii_only?
        @line_assertion_method_i = :assrt_expected_line_equals_actual_line
      else
        @line_assertion_method_i = :assrt_expected_rx_matches_actual_line
      end
      if st.unparsed_exists
        raise ::ArgumentError, "no: #{ st.current_token }" ; nil
      end
    end

    def init_expectation_stream x_a
      if exp_stream
        @exp_stream.reinitialize 0, x_a
      else
        @exp_stream = Callback_.iambic_stream.new 0, x_a
      end
      nil
    end

    attr_reader :exp_stream

    def init_actual_stream
      if ! act_stream
        @act_stream = Callback_.iambic_stream.new 0, build_baked_em_a
      end
      nil
    end

    attr_reader :act_stream

    def build_baked_em_a
      @IO_spy_group.release_lines
    end

    def invocation_string
      self.class.fake_app_name
    end

    def sub_action_s_a
      nil
    end

  end
end
