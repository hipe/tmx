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

    def expect_errored
      expect_no_more_lines
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
      grp = TestSupport_::IO::Spy::Group.new
      grp.do_debug_proc = -> { do_debug }
      grp.debug_IO = TestSupport_::Lib_::Stderr[]
      grp.add_stream :i, :_no_instream_
      grp.add_stream :o
      grp.add_stream :e
      @IO_spy_group = grp
      @client = Brazen_::CLI.new( nil, * grp.values_at( :o, :e ), [ 'bzn' ] )
      @exitstatus = @client.invoke argv ; nil
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
        }#{ current_iambic_token.inspect }"
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
