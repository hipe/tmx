# (because the asset file is standalone, we have to do more work here)

require 'skylab/yacc2treetop'
require 'skylab/test_support'

module Skylab::Yacc2Treetop::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  # TestSupport_::Quickie.enable_kernel_describe

  module ModuleMethods

    def use sym

    o[ :expect_CLI ] = -> tcc do
      require 'skylab/brazen'
      ::Skylab::Brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
      tcc.extend CLI_Module_Methods__
      tcc.include CLI_Instance_Methods__
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

      first = true
      frame = nil

      define_method :_frame do

        if first
          first = false
          frame = __build_frame argv
        end
        frame
      end
    end
  end

  module CLI_Instance_Methods__

    def flush_baked_emission_array  # use [#ts-023.A] frame technique

      fr = _frame
      @exitstatus = fr.exitstatus
      @IO_spy_group_for_expect_stdout_stderr = fr.IO_spy_group.dup
      super
    end

    def __build_frame argv

      using_expect_stdout_stderr_invoke_via_argv argv
      flush_frozen_frame_from_expect_stdout_stderr__
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

  Callback_ = ::Skylab::Callback
  Home_ = ::Skylab::Yacc2Treetop

  _TEST_DIR = ::File.join( Home_.sidesys_path_, TestSupport_::TEST_DIR_FILENAME_ )

  FIXTURES_PATH = ::File.join _TEST_DIR, 'fixtures'

end
