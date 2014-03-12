require_relative '../../test-support/core'
require_relative '../core'

module Skylab::Slake::TestSupport

  Slake = ::Skylab::Slake

  ::Skylab::Callback::Autoloader[ self, Slake.dir_pathname.join( 'test' ) ]  # #while:[#ts-031]

  ::Skylab::TestSupport::Regret[ Slake_TestSupport = self ]

  module CONSTANTS
    TEST_ROOT_DIR = ::File.expand_path '..', __FILE__
    FIXTURES_DIR = "#{ TEST_ROOT_DIR }/fixtures"
    TMP_DIR = ::File.expand_path '../../../../../tmp', __FILE__
    TEST_BUILD_DIR = ::File.join(TMP_DIR, 'build_dir')
    TestSupport = ::Skylab::TestSupport
    include ::Skylab::Slake  # e.g just say `Task`
  end

  include CONSTANTS  # find [sl] t.s

  Headless = ::Skylab::Callback::Autoloader.require_sidesystem :Headless

end
