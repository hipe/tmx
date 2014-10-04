require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Flex2Treetop::MyTestSupport

  Flex2Treetop = ::Skylab::Flex2Treetop
  MyTestSupport = self
  Skylab_Headless = ::Skylab::Headless
  TestSupport = ::Skylab::TestSupport

  Flex2Treetop::Autoloader_[ self, Flex2Treetop.dir_pathname.join( 'test' ) ]

  extend TestSupport::Quickie

  # for #posterity we are keeping the below name which is mythically
  # believed to be the origin of the idea for the whole Headless library

  module Headless

    # ~ test phase.

    module InstanceMethods

      def debug!
        @do_debug = true
      end
      attr_reader :do_debug
      def debug_IO
        Skylab_Headless::System::IO.some_stderr_IO
      end

      def _IO_spy_group
        @IO_spy_group ||= build_IO_spy_group
      end

      def build_IO_spy_group
        grp = TestSupport::IO::Spy::Group.new
        grp.debug_IO = debug_IO
        grp.do_debug_proc = -> { do_debug }
        grp.add_stream :stdin do |io|
          io.is_tty = true
        end
        add_any_outstream_to_IO_spy_group grp
        grp.add_stream :stderr
        grp
      end

      def fixture name_i
        self.class.fixture name_i
      end
    end

    module ModuleMethods
      def fixture name_i
        _path_s = Flex2Treetop::FIXTURE_H__.fetch name_i
        ::Skylab.dir_pathname.join( _path_s ).to_s
      end
    end

    module InstanceMethods
      def tmpdir
        Tmpdir__[ -> { do_debug && debug_IO } ]
      end
    end
    Tmpdir__ = -> do
      p = -> dbg_IO_p do
        _pn = Skylab_Headless::System.defaults.tmpdir_pathname.join 'f2tt'
        x_a = [ :path, _pn ]
        dbg_IO = dbg_IO_p[]
        if dbg_IO
          x_a.push :infostream, dbg_IO, :be_verbose, true
        end
        td = TestSupport.tmpdir.via_iambic x_a
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
        x_a.length.zero? or
          fail "unexpected #{ Skylab_Headless.inspect x_a.first }"
        line = gets_some_chopped_line  # #storypoint-050
        do_expect_styled and line = expct_styled( line )
        if string_matcher_x.respond_to? :named_captures
          line.should match string_matcher_x
        else
          line.should eql string_matcher_x
        end ; nil
      end
      #
      def expct_styled line
        Skylab_Headless::CLI::Pen::FUN::Unstyle_styled[ line ] or
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
        _grp = _IO_spy_group
        @IO_spy_group = :_IO_spy_group_was_baked_
        _a = _grp.release_lines
        MyTestSupport::Line_Source__.new dbg_IO do |ls|
          ls.init_upstream_line_source_with_emissions :stderr, _a
        end
      end

      def build_line_source_from_open_file_IO io
        MyTestSupport::Line_Source__.new dbg_IO do |ls|
          ls.init_upstream_line_source_with_open_file_IO io
        end
      end

      def change_line_source_channel_to chan_i
        @ln_source.change_upstream_scanner_to_channel chan_i ; nil
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

      define_method :_EM,
        Skylab_Headless::CLI::Pen::FUN::Stylify.curry[ %i( yellow ) ]
    end
  end
  XX = '@ rb_file_s_stat '.freeze  # 2.1.0 added this
end
