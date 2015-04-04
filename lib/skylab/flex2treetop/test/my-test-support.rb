require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Flex2Treetop::MyTestSupport

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  def self.extended tcm
    tcm.extend Headless::ModuleMethods
    tcm.include Headless::InstanceMethods
  end

  # for #posterity we are keeping the below name which is mythically
  # believed to be the origin of the idea for the whole Headless library

  module Headless

    # ~ test phase.

    module ModuleMethods

      def use sym

        Top_TS_.const_get(
          Callback_::Name.via_variegated_symbol( sym ).as_const, false
        )[ self ]
      end
    end

    module InstanceMethods

      def fixture_flex_ sym
        Fixture_file__[ sym, :flex ]
      end

      def fixture_file_ sym, cat_sym
        Fixture_file__[ sym, cat_sym ]
      end

      # ~

      def _IO_spy_group
        @IO_spy_group ||= __build_IO_spy_group
      end

      def __build_IO_spy_group

        grp = TestSupport_::IO.spy.group.new
        grp.debug_IO = debug_IO
        grp.do_debug_proc = -> { do_debug }
        grp.add_stream :stdin do |io|
          io.is_tty = true
        end
        add_any_outstream_to_IO_spy_group grp
        grp.add_stream :stderr
        grp
      end

      # ~

      def tmpdir
        Tmpdir___[ -> { do_debug && debug_IO } ]
      end

      # ~ support

      attr_reader :do_debug

      def debug!
        @do_debug = true
      end

      def debug_IO
        TestLib_::System[].IO.some_stderr_IO
      end
    end

    Fixture_file__ = -> do

      h = {}

      -> sym, cat_sym do

        h_ = h.fetch cat_sym do
          h[ cat_sym ] = {}
        end

        h_.fetch sym do

          h_[ sym ] = ::File.join( FIXTURE_FILES_DIR_, "#{ sym }.#{ cat_sym }" ).freeze
        end
      end
    end.call

    Tmpdir___ = -> do
      p = -> dbg_IO_p do
        _pn = TestLib_::System[].filesystem.tmpdir_pathname.join 'f2tt'
        x_a = [ :path, _pn ]
        dbg_IO = dbg_IO_p[]
        if dbg_IO
          x_a.push :be_verbose, true, :debug_IO, dbg_IO
        end
        td = TestSupport_.tmpdir.new_via_iambic x_a
        p = -> _ { td }
        td
      end
      -> dbg_IO_p { p[ dbg_IO_p ] }
    end.call

    # ~ assertion phase.

    module InstanceMethods

      def expect * x_a, string_matcher_x
        if x_a.length.nonzero? && :styled == x_a.first
          x_a.shift ; do_expect_styled = true
        end
        x_a.length.zero? or fail say_unexpected( x_a.first )
        line = gets_some_chopped_line  # #storypoint-050
        do_expect_styled and line = expct_styled( line )
        if string_matcher_x.respond_to? :named_captures
          line.should match string_matcher_x
        else
          line.should eql string_matcher_x
        end ; nil
      end

      def say_unexpected x
        "unexpected #{ TestLib_::Strange[ x ] }"
      end

      def expct_styled line
        F2TT_.lib_.CLI_pen.unstyle_styled( line ) or
          fail "expected styled, was not: #{ line }"
      end

      def expect_failed
        expect_no_more_lines
        expect_result_for_failure
      end

      def expect_succeeded
        expect_no_more_lines
        expect_result_for_success
      end

      def gets_some_chopped_line
        line_source.gets_some_chopped_line
      end

      def skip_until_last_N_lines d
        line_source.skip_until_last_N_lines d
      end

      def skip_contiguous_chopped_lines_that_match rx
        line_source.skip_contiguous_chopped_lines_that_match rx
      end

      def gets_some_first_chopped_line_that_does_not_match rx
        line_source.gets_some_first_chopped_line_that_does_not_match rx
      end

      def skip_all_contiguous_emissions_on_channel chan_i
        line_source.skip_all_contiguous_emissions_on_channel chan_i
      end

      def skip_any_comment_lines
        skip_contiguous_chopped_lines_that_match COMMENT_RX__
      end

      COMMENT_RX__ = /\A[ \t]*#/

      def expect_no_more_lines
        self._NO
        line_source.assert_no_more_lines
      end

      def init_line_source_as x
        ln_source and fail "line source is already set"
        @ln_source = x ; nil
      end

      def line_source
        @ln_source ||= bld_line_source
      end

      attr_reader :ln_source

      def bld_line_source

        self._WAHT

        _grp = _IO_spy_group
        @IO_spy_group = :_IO_spy_group_was_baked_
        _a = _grp.release_lines
        Top_TS_::Line_Source__.new dbg_IO do |ls|
          ls.init_upstream_line_source_with_emissions :stderr, _a
        end
      end

      def build_line_source_from_open_file_IO io

        self._WHAT

        Top_TS_::Line_Source__.new dbg_IO do |ls|
          ls.init_upstream_line_source_with_open_file_IO io
        end
      end

      def change_line_source_channel_to chan_i
        @ln_source.change_upstream_stream_to_channel chan_i ; nil
      end

      def dbg_IO
        do_debug && debug_IO
      end

      def expect_result_for_failure
        @result.should eql false
      end

      def expect_result_for_success
        @result.should eql true
      end

      # define_method :_EM, F2TT_.lib_.CLI_pen.stylify.curry[ %i( yellow ) ]
    end
  end

  module Expect_Event

    class << self

      def [] tcm

        tcm.include Callback_.test_support::Expect_Event::Test_Context_Instance_Methods
        tcm.include self
      end
    end  # >>

    def black_and_white_expression_agent_for_expect_event

      F2TT_::Brazen_::API.expression_agent_instance
    end
  end

  Expect_Line = -> tcm do

    TestSupport_::Expect_line[ tcm ]
  end

  Callback_ = ::Skylab::Callback

  module TestLib_

    sidesys = Callback_::Autoloader.build_require_sidesystem_proc

    Bsc__ = sidesys[ :Basic ]

    HL__ = sidesys[ :Headless ]

    MH__ = sidesys[ :MetaHell ]

    Strange = -> x do
      MH__[].strange x
    end

    System = -> do
      HL__[].system
    end
  end

  F2TT_ = ::Skylab::Flex2Treetop
  FIXTURE_FILES_DIR_ = F2TT_.dir_pathname.join( 'test/fixture-files' ).to_path
  ICK_ = '@ rb_file_s_stat '.freeze  # 2.1.0 added this
  NIL_ = nil
  REAL_PROGNAME_ = 'flex2treetop'.freeze  # no easy way to mutate this?
  Stderr_Resources_ = ::Struct.new :stderr
  Top_TS_ = self
end
