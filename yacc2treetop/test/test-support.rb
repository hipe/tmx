# (because the asset file is standalone, we have to do more work here)

require 'skylab/yacc2treetop'
require 'skylab/test_support'

module Skylab::Yacc2Treetop::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  # TestSupport_::Quickie.enable_kernel_describe

  module ModuleMethods

    o = {}

    o[ :expect_CLI ] = -> tcc do
      require 'skylab/brazen'
      ::Skylab::Brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
      tcc.extend CLI_Module_Methods__
      tcc.include CLI_Instance_Methods__
    end

    o[ :expect_event ] = -> tcc do
      Common_.test_support::Expect_Event[ tcc ]
    end

    o[ :memoizer_methods ] = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end

    define_method :use do |sym|
      o.fetch( sym )[ self ]
    end

    def _share sym, & p
      dangerous_memoize sym, & p
    end
  end

  module InstanceMethods

    INVITE_RX = /\Ayacc2treetop -h for help\z/
    USAGE_RX = /\Ausage: yacc2treetop .*<yaccfile>/

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  module CLI_Module_Methods__

    def invoke * argv
      _invoke_by_args do
        argv
      end
    end

    def invoke_by & single_arg
      _invoke_by_args do
        [ single_arg[] ]
      end
    end

    def _invoke_by_args & args_p

      first = true
      state = nil

      define_method :invocation_state_ do

        if first
          first = false
          _argv = args_p[]
          state = __build_invocation_state _argv
        end
        state
      end
    end
  end

  module CLI_Instance_Methods__

    def flush_baked_emission_array  # use [#ts-023.A] frame technique

      _state = invocation_state_
      _state.lines
    end

    def __build_invocation_state argv

      using_expect_stdout_stderr_invoke_via_argv argv
      flush_frozen_state_from_expect_stdout_stderr
    end

    define_method :get_invocation_strings_for_expect_stdout_stderr, -> do
      a = %w( y2tt ).freeze
      -> do
        a
      end
    end.call

    def subject_CLI
      Home_::CLI
    end
  end

  Common_ = ::Skylab::Common
  Home_ = ::Skylab::Yacc2Treetop

  _TEST_DIR = ::File.join( Home_.sidesys_path_, TestSupport_::TEST_DIR_FILENAME_ )

  FIXTURES_PATH = ::File.join _TEST_DIR, 'fixtures'

end
