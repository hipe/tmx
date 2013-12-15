require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI

  ::Skylab::Headless::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  Headless = Headless ; MetaHell = MetaHell

  extend TestSupport::Quickie  # e.g sibling 'path tools'

  module InstanceMethods

    CONSTANTS::Normalize_argv = -> x_a do
      1 == x_a.length and a = ::Array.try_convert( x_a.first )
      a || x_a
    end
  end

  module ModuleMethods

    # ~ DSL-phase support

    def sandbox_module
      mod = nearest_test_node
      if mod.const_defined? SANDBOX_I__, false
        mod.const_get SANDBOX_I__
      else
        mod.const_set SANDBOX_I__, ::Module.new
      end
    end
    SANDBOX_I__ = :Sbx
  end

  module InstanceMethods

    include CONSTANTS

    # ~ test-phase support

    def from_workdir &p
      r = nil
      Headless::Services::FileUtils.cd workdir do
        r = p[]
      end ; r
    end

    def workdir
      Probably_existant_tmpdir__[ do_debug ]
    end

    Probably_existant_tmpdir__ = -> do
      p = -> do_debug do
        td = CLI_TestSupport.tmpdir
        do_debug and td.debug!
        td.exist? or td.prepare
        p = -> _ { td } ; td  # not failsafe
      end
      -> yes { p[ yes ] }
    end.call

    def mock_client
      @mock_client ||= build_mock_client
    end

    def build_mock_client
      Mock_Client__.new do_debug && debug_IO
    end

    # ~ assertion-phase support

    def expect_usage_line_with s
      expect :styled, "usage: #{ s }"
    end

    def expect_invite_line_with s
      expect :styled, "use #{ s } -h for help"
    end

    def expect * x_a
      line = serr_a.shift or fail "expected more serr lines, had none"
      if :styled == x_a[ 0 ]
        x_a.shift
        line_ = Headless::CLI::Pen::FUN::Unstyle_styled[ line ]
        line_ or raise "expected line to be styled, was not: #{ line.inspect }"
        line = line_
      end
      x = x_a.shift
      x_a.length.zero? or raise ::ArgumentError, "unexpected: #{ x_a[0].class }"
      if x.respond_to? :named_captures
        line.should match x
      else
        line.should eql x
      end
    end

    def expect_no_more_serr_lines
      number_of_reamaining_stderr_lines.zero? or fail "expected no more lines#{
        }, had: #{ serr_a.fetch( 0 ).inspect }"
    end

    def expect_a_few_more_serr_lines
      a_few_more.should be_include number_of_reamaining_stderr_lines
    end

    define_method :a_few_more, MetaHell::FUN::Memoize[ -> { 1..2 } ]

    def number_of_reamaining_stderr_lines
      serr_a.length
    end

    def expect_neutralled
      expect_no_more_serr_lines
      expect_neutral_result
    end

    def expect_neutral_result
      @result.should be_nil
    end

    def expect_succeeded
      expect_no_more_serr_lines
      expect_result_for_success
    end

    def expect_result_for_success
      @result.should eql true
    end

    def expect_failed
      expect_no_more_serr_lines
      @result.should eql false
    end

    let :serr_a do
      serr_a_bake_notify
    end

    def expect_text  # #todo:narratize-this
      FUN.expect_text
    end
  end

  class Mock_Client__  # (newer smaller version of [#144] client spy)
    def initialize debug_IO
      @a = [] ; @debug_IO = debug_IO
    end
    attr_reader :a
    def pen
      Headless::CLI::Pen::MINIMAL
    end
    def emit_help_line_p
      emit_info_line_p
    end
    def emit_info_line_p
      @emit_info_line_p ||= method :emit_info_line
    end
    def emit_info_line s
      @debug_IO and @debug_IO.puts [ :info, s ].inspect
      @a << s ; nil
    end
    def normalized_invocation_string
      'yerp'
    end
    def release
      r = @a ; @a = :_released_ ; r
    end
  end
end
