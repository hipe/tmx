require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI

  ::Skylab::Headless::TestSupport[ TS_ = self ]

  include Constants

  Autoloader_ = Autoloader_
  Home_ = Home_

  extend TestSupport_::Quickie  # e.g sibling 'path tools'

  module Constants
    Autoloader_ = Home_::Autoloader_
  end

  module InstanceMethods

    Constants::Normalize_argv = -> x_a do
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
        mod_ = ::Module.new
        mod.const_set SANDBOX_I__, mod_
        Autoloader_[ mod_ ]
        mod_
      end
    end
    SANDBOX_I__ = :Sbx
  end

  module InstanceMethods

    include Constants

    # ~ test-phase support

    def from_workdir &p
      r = nil
      Home_::Library_::FileUtils.cd workdir do
        r = p[]
      end ; r
    end

    def workdir
      Probably_existant_tmpdir__[ do_debug ]
    end

    Probably_existant_tmpdir__ = -> do
      p = -> do_debug do
        td = TS_.tmpdir
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
      line = expect_at_least_one_more_serr_line
      if :styled == x_a[ 0 ]
        x_a.shift
        line = expect_that_this_line_is_styled_and_unstyle_it line
      end
      x = x_a.shift
      x_a.length.zero? or raise ::ArgumentError, "unexpected: #{ x_a[0].class }"
      if x.respond_to? :named_captures
        line.should match x
      else
        line.should eql x
      end
    end

    def expect_at_least_one_more_serr_line
      serr_a.shift or fail "expected more serr lines, had none"
    end

    def expect_that_this_line_is_styled_and_unstyle_it line

      line_ = Home_.lib_.brazen::CLI::Styling.unstyle_styled line
      line_ or raise "expected line to be styled, was not: #{ line.inspect }"
      line_
    end

    def crunchify

      s = expect_at_least_one_more_serr_line

      x = Home_.lib_.brazen::CLI::Styling.parse_styles s

      x or fail "expected styled string, had: #{ s.inspect }"
      y = []
      if :string == x.fetch( 0 ).first
        y << x.shift.last
      end
      begin
        xx = x.shift
        :style == xx.first or fail "parse failure: #{ xx.inspect }"
        style_i = crunchify_style_d_a xx[ 1 .. -1 ]
        :string == x.first.first or fail "parse failure: #{ xx.inspect }"
        str_s = x.shift.last
        xx = x.shift
        xx == END_STYLE__ or fail "parse failure: #{ xx.inspect }"
        y << [ style_i, str_s ]
        :string == x.first.first or fail "parse failure: #{ x.first.inspect }"
        y << x.shift.last
      end while x.length.nonzero?
      y
    end

    def crunchify_style_d_a d_a
      y = []
      if (( idx = d_a.index 1 ))
        y << :strong
        d_a[ idx ] = nil ; d_a.compact!
      end
      y.concat d_a.map( & COLOR_MAP__.method( :fetch ) )
      ( y * '_' ).intern
    end

    COLOR_MAP__ = { 32 => :green }.freeze
    END_STYLE__ = [ :style, 0 ]

    def expect_blank
      expect ''
    end

    def expect_header i
      expect :styled, "#{ i }:"
    end

    def expect_no_more_serr_lines
      number_of_reamaining_stderr_lines.zero? or fail "expected no more lines#{
        }, had: #{ serr_a.fetch( 0 ).inspect }"
    end

    def expect_a_few_more_serr_lines
      a_few_more.should be_include number_of_reamaining_stderr_lines
    end

    define_method :a_few_more,
      Home_::Library_::Memoize[ -> { 1..2 } ]

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
      expect_result_for_failure
    end

    def expect_result_for_failure
      @result.should eql false
    end

    let :serr_a do
      serr_a_bake_notify
    end
  end

  class Mock_Client__  # (newer smaller version of [#144] client spy)
    def initialize debug_IO
      @a = [] ; @debug_IO = debug_IO
    end
    attr_reader :a
    def pen
      Home_::CLI.pen.minimal_instance
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
    def normalized_invocation_string_prts y
      y << YERP__ ; nil
    end
    YERP__ = 'yerp'.freeze
    def release
      r = @a ; @a = :_released_ ; r
    end
  end

  Subject_ = -> do
    Home_::CLI
  end
end
