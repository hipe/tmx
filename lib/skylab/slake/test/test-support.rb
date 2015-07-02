require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Slake::TestSupport

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Home_ = ::Skylab::Slake

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ Slake_TestSupport = self ]

  module Constants
    TEST_ROOT_DIR = ::File.expand_path '..', __FILE__
    FIXTURES_DIR = "#{ TEST_ROOT_DIR }/fixtures"
    TMP_DIR = ::File.expand_path '../../../../../tmp', __FILE__
    TEST_BUILD_DIR = ::File.join(TMP_DIR, 'build_dir')
    TestSupport_ = TestSupport_
  end

  module TestLib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Tee = -> do
      System_lib___[]::IO::Mappers::Tee
    end

    System_lib___ = sidesys[ :System ]
  end
end
