module Skylab ; end
module Skylab::Slake ; end
module Skylab::Slake::TestSupport ; end

module Skylab::Slake::TestSupport::Constants
  TEST_ROOT_DIR = File.expand_path('../..', __FILE__)
  FIXTURES_DIR = "#{TEST_ROOT_DIR}/fixtures"
  TMP_DIR = File.expand_path('../../../../../../tmp', __FILE__)
  TEST_BUILD_DIR = File.join(TMP_DIR, 'build_dir')
end

