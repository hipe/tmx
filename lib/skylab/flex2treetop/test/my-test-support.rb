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
        TestSupport_.debug_IO
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
        _pn = F2TT_::LIB_.system.filesystem.tmpdir_pathname.join 'f2tt'
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

  Expect_Stdout_Stderr = -> tcm do

    tcm.include TestSupport_::Expect_Stdout_Stderr::InstanceMethods
    tcm.send :define_method, :expect, tcm.instance_method( :expect )  # :+#this-rspec-annoyance
  end

  Callback_ = ::Skylab::Callback

  Mock_resources_ = Callback_.memoize do
    Mock_Resources_.new Mock_interactive_stdin_[]
  end

  Mock_Resources_ = ::Struct.new :sin, :sout, :serr

  Mock_interactive_stdin_ = Callback_.memoize do
    Mock_Interactive_Stderr___.new
  end

  class Mock_Interactive_Stderr___
    def tty?
      true
    end
  end


  F2TT_ = ::Skylab::Flex2Treetop
  FIXTURE_FILES_DIR_ = F2TT_.dir_pathname.join( 'test/fixture-files' ).to_path
  ICK_ = '@ rb_file_s_stat '.freeze  # 2.1.0 added this
  NIL_ = nil
  REAL_PROGNAME_ = 'flex2treetop'.freeze  # no easy way to mutate this?
  Stderr_Resources_ = ::Struct.new :serr
  Top_TS_ = self
end
