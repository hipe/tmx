require_relative '../core'

Skylab::CodeMolester::Autoloader_.require_sidesystem :TestSupport

module Skylab::CodeMolester::TestSupport

  TestLib_ = ::Module.new

  module Constants
    Home_ = ::Skylab::CodeMolester
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  TestSupport_ = TestSupport_

  TestSupport_::Regret[ self ]

  TestSupport_::Quickie.enable_kernel_describe

  Home_ = Home_

  Constants::Tmpdir_instance_ = Home_::Callback_.memoize do
    TestSupport_.tmpdir.new_with(
      :max_mkdirs, 2,
      :path, Home_.lib_.system_default_tmpdir_pathname.join( 'co-mo' ),
      :be_verbose, false )
  end

  module InstanceMethods

    include Constants # refer to constants from i.m's

    def debug!
      @do_debug = true ; nil
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  module Constants::TestLib_

    Bzn = -> do
      Home_::Lib_::Brazen[]
    end

    Expect_line = -> do
      TestSupport_::Expect_line
    end

  end
end
