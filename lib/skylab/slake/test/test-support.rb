require_relative '../../test-support/core'
require_relative '../core'

module Skylab::Slake::TestSupport
  ::Skylab::TestSupport::Regret[ Slake_TestSupport = self ]

  module CONSTANTS
    TEST_ROOT_DIR = ::File.expand_path '..', __FILE__
    FIXTURES_DIR = "#{ TEST_ROOT_DIR }/fixtures"
    TMP_DIR = File.expand_path '../../../../../tmp', __FILE__
    TEST_BUILD_DIR = ::File.join(TMP_DIR, 'build_dir')

    MetaHell = ::Skylab::MetaHell
  end

  include CONSTANTS

  MetaHell = MetaHell             # (prettier from support classes below)
end
