require 'skylab/code_metrics'
require 'skylab/test_support'

module Skylab::CodeMetrics::TestSupport

  def self.[] tcc
    tcc.extend Module_Methods___
    tcc.include Instance_Methods___
  end

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  module Module_Methods___

    cache = {}
    define_method :use do | sym |
      _ = cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
      _[ self ]
    end
  end

  Home_ = ::Skylab::CodeMetrics

  Callback_ = Home_::Callback_

  module Instance_Methods___

    define_singleton_method :_dangerous_memoize, TestSupport_::DANGEROUS_MEMOIZE

    _dangerous_memoize :toplevel_helpscreen_actions_ do

      _x = toplevel_help_screen_.lookup 'actions'
      bx = Callback_::Box.new
      _x.children.each do | cx |
        bx.add cx.x.get_column_A_content, cx
      end
      bx
    end

    _dangerous_memoize :toplevel_help_screen_ do

      invoke '-h'
      flush_invocation_to_help_screen_oriented_state
    end

    def subject_CLI
      Home_::CLI
    end

    _dangerous_memoize :memoized_invocation_strings_for_expect_stdout_stderr_ do
      get_invocation_strings_for_expect_stdout_stderr
    end

    s = '[CoMe]'
    define_method :get_invocation_strings_for_expect_stdout_stderr_ do
      [ s ]  # some places need this as mutable (to build sub-program name)
    end

    def subject_API
      Home_.application_kernel_
    end

    def black_and_white_expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # -- for `use`

  CLI_Support_Expectations = -> tcc do
    Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
  end

  Expect_Event = -> tcc do
    Callback_.test_support::Expect_event[ tcc ]
  end

  Expect_Stdout_Stderr = -> tcc do
    tcc.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
  end

  Memoization_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Fixture_file_ = -> s do

    ::File.join Fixture_file_directory_[], s
  end

  Fixture_file_directory_ = Callback_.memoize do

    ::File.join Fixture_tree_directory_[], 'fixture-files-one'
  end

  Fixture_tree_directory_ = Callback_.memoize do

    TS_.dir_pathname.join( 'fixture-trees/fixture-tree-one' ).to_path
  end

  module Sandbox_
    TestSupport_::Sandbox.enhance( self ).kiss_with 'KLS_'
  end

  Callback_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = "\n"
  NIL_ = nil
  SPACE_ = Home_::SPACE_
  TS_ = self
end
