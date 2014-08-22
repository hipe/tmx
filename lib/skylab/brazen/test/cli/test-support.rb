require_relative '../test-support'

module Skylab::Brazen::TestSupport::CLI

  ::Skylab::Brazen::TestSupport[ TS_ = self ]

  Brazen_ = ::Skylab::Brazen
  TestSupport_ = ::Skylab::TestSupport

  module CONSTANTS
    Brazen_ = Brazen_
    TestSupport_ = TestSupport_
  end

  extend TestSupport_::Quickie

  module InstanceMethods

    # ~ common business assertions

    def expect_branch_pattern_zero
      expect_expecting_action_line
      expect_usage_line
      expect_invite_line
      expect_errored
    end

    def expect_branch_pattern_one_one
      expect :styled, /\Aunrecognized action ['"]?fiffle['"]?\z/
      _rx = bld_known_actions_rx
      expect :styled, _rx
      expect_invite_line
      expect_errored
    end

    def bld_known_actions_rx
      /\Aknown actions are \(#{ self.class::EXPECTED_ACTION_NAME_S_A.
        map { |s| "'?#{ ::Regexp.escape s }'?" } * ', ' }\)\z/
    end

    def expect_branch_pattern_one_two
      expect 'invalid option: -x'
      expect_invite_line
      expect_errored
    end

    def expect_expecting_action_line
      expect :styled, 'expecting <action>'
    end

    def expect_help_screen_first_half
      expect_usage_line
      expect_secondary_syntax_line

      expect_maybe_a_blank_line
      expect_description_line

      expect_maybe_a_blank_line
      expect_header_line 'options'
      expect_options

      expect_maybe_a_blank_line
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

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def invoke * argv
      invoke_via_argv argv
    end

    def invoke_via_argv argv
      grp = TestSupport_::IO::Spy::Group.new
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

    def debug_IO
      TestSupport_::Lib_::Stderr[]
    end

    def prepare_invocation
    end

    # ~ assertion phase

    def expect * x_a
      load_expect_the_first_time
      expect_via_arg_list x_a
    end

    def load_expect_the_first_time
      cls = self.class
      cls.include Brazen_::Entity::Iambic_Methods_via_Scanner__,
        Brazen_::Entity::Iambic_Methods__
      cls.send :define_method, :expect do |*x_a|
        expect_via_arg_list x_a
      end ; nil
    end

    def expect_no_more_lines
      unparsed_iambic_exists and fail "expected no more lines, had #{
        }#{ current_iambic_token.to_a.inspect }"
    end

    def expect_maybe_a_blank_line
      if unparsed_iambic_exists and NEWLINE__ == current_iambic_token.string
        advance_iambic_scanner_by_one ; nil
      end
    end

    NEWLINE__ = "\n".freeze

    def expect_header_line s
      expect :styled, "#{ s }:"
    end

    def expect_via_arg_list x_a
      prs_expectation x_a
      init_emission_scan
      unparsed_iambic_exists or fail "expected more lines, had none."
      @emission = iambic_property
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
      init_expectation_scan x_a
      if :styled == current_iambic_token
        @style_is_expected = true
        advance_iambic_scanner_by_one
      else
        @style_is_expected = false
      end
      x = iambic_property
      @line_assertion_x = x
      if x.respond_to? :ascii_only?
        @line_assertion_method_i = :assrt_expected_line_equals_actual_line
      else
        @line_assertion_method_i = :assrt_expected_rx_matches_actual_line
      end
      unparsed_iambic_exists and
        raise ::ArgumentError, "no: #{ current_iambic_token }" ; nil
    end

    def init_expectation_scan x_a
      if expectation_scanner
        @expectation_scanner.send :initialize, 0, x_a
      else
        @expectation_scanner = Brazen_::Entity::Iambic_Scanner.new 0, x_a
      end
      @scan = @expectation_scanner ; nil
    end

    def init_emission_scan
      if ! emission_scanner
        _em_a = build_baked_em_a
        @emission_scanner = Brazen_::Entity::Iambic_Scanner.new 0, _em_a
      end
      @scan = @emission_scanner ; nil
    end

    def build_baked_em_a
      @IO_spy_group.release_lines
    end

    attr_reader :expectation_scanner, :emission_scanner

  end
end
