# (because the asset file is standalone, we have to do more work here)

top = ::File.expand_path '../../../../..', __FILE__

load ::File.join( top, 'bin/tmx-yacc2treetop' )  # doesn't need anything else

require ::File.join( top, 'lib/skylab' )

require 'skylab/test-support/core'

Skylab::Yacc2Treetop::TestSupport = ::Module.new

Skylab::Yacc2Treetop::TestSupport::DIR_PATHNAME__ =

  ::File.join( top, 'lib/skylab/yacc2treetop' )

module Skylab::Yacc2Treetop::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  def self.dir_pathname
    # (without this, [ts] regret will crawl up to the unadorned sidesystem mod.)
    self._EEK
  end

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  # TestSupport_::Quickie.enable_kernel_describe

  module ModuleMethods

    def use sym

      case sym
      when :expect_event
        Callback_.test_support::Expect_Event[ self ]
      when :expect_CLI
        ::Kernel.require 'skylab/brazen/core'
        ::Skylab::Brazen.test_support.CLI::Expect_CLI[ self ]
        extend CLI_Module_Methods__
        include CLI_Instance_Methods__
      else
        self._CASE
      end
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
      flush_frozen_frame_from_expect_stdout_stderr
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

  Home_ = ::Skylab::Yacc2Treetop
  Callback_ = ::Skylab::Callback
  FIXTURES_PATH = ::File.join DIR_PATHNAME__, 'test/fixtures'

end
