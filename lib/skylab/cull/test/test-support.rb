require_relative '../core'

::Skylab::Cull::Autoloader_.require_sidesystem :TestSupport

module Skylab::Cull::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  module Constants
    Cull_ = ::Skylab::Cull
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  TestSupport_ = TestSupport_

  extend TestSupport_::Quickie

  Cull_ = Cull_

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def prepare_tmpdir

      fs =  Cull_._lib.filesystem
      path = fs.tmpdir_pathname.join( 'culio' ).to_path
      td = fs.tmpdir(
        :path, path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )

      td.clear
    end

    def freshly_initted_path
      TS_::Fixtures::Directories[ :freshly_initted ]
    end

    def config_path
      Config_path___[]
    end

    # ~ #hook-outs for [br]

    def black_and_white_expression_agent_for_expect_event
      Cull_::Brazen_::API.expression_agent_instance
    end

    def subject_API
      Cull_::API
    end
  end

  Config_path___ = Cull_::Callback_.memoize do
    o = Cull_::Models_::Survey
    ::File.join o::FILENAME_, o::CONFIG_FILENAME_
  end

  Expect_event_ = -> test_context_module do
    Cull_::Brazen_.test_support::Expect_Event[ test_context_module ]
  end

  DASH_ = '-'
  NEWLINE_ = "\n"
  UNDERSCORE_ = '_'
end
