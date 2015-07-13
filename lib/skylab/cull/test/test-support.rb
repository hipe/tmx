require_relative '../core'

::Skylab::Cull::Autoloader_.require_sidesystem :TestSupport

module Skylab::Cull::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  module Constants
    Home_ = ::Skylab::Cull
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  TestSupport_ = TestSupport_

  extend TestSupport_::Quickie

  Home_ = Home_

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # ~ paths for READ ONLY:

    def freshly_initted_path_
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

      td = Home_.lib_.filesystem.tmpdir(
        :path, tmpdir_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )

      td.clear
    end

    def tmpdir_path

      ::File.join Home_.lib_.filesystem.tmpdir_path, 'culio'
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
      Home_::Brazen_::API.expression_agent_instance
    end

    def subject_API
      Home_::API
    end
  end

  Config_filename___ = Home_::Callback_.memoize do
    o = Home_::Models_::Survey
    ::File.join o::FILENAME_, o::CONFIG_FILENAME_
  end

  Expect_event_ = -> test_context_module do
    Home_::Callback_.test_support::Expect_Event[ test_context_module ]
  end

  DASH_ = '-'
  NEWLINE_ = "\n"
  UNDERSCORE_ = '_'
end
