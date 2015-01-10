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

    # ~ paths for READ ONLY:

    def freshly_initted_path
      dir :freshly_initted
    end

    def dir sym
      TS_::Fixtures::Directories[ sym ]
    end

    def file sym
      TS_::Fixtures::Files[ sym ]
    end

    # ~ mutable workspace methods

    def prepare_tmpdir_with_patch sym
      td = prepare_tmpdir
      td.patch_via_path TS_::Fixtures::Patches[ sym ]
      td
    end

    def prepare_tmpdir

      td = Cull_.lib_.filesystem.tmpdir(
        :path, tmpdir_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )

      td.clear
    end

    def tmpdir_path
      Cull_.lib_.filesystem.tmpdir_pathname.join( 'culio' ).to_path
    end

    # ~ assertion support

    def content_of_the_file td
      ::File.read( td.to_pathname.join( config_filename ).to_path )
    end

    def config_filename
      Config_filename___[]
    end

    # ~ #hook-outs for [br]

    def black_and_white_expression_agent_for_expect_event
      Cull_::Brazen_::API.expression_agent_instance
    end

    def subject_API
      Cull_::API
    end
  end

  Config_filename___ = Cull_::Callback_.memoize do
    o = Cull_::Models_::Survey
    ::File.join o::FILENAME_, o::CONFIG_FILENAME_
  end

  Expect_event_ = -> test_context_module do
    Cull_::Callback_.test_support::Expect_Event[ test_context_module ]
  end

  DASH_ = '-'
  NEWLINE_ = "\n"
  UNDERSCORE_ = '_'
end
