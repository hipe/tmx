module Skylab ; end
module Skylab::Dependency ; end
module Skylab::Dependency::TestSupport ; end

module Skylab::Dependency::TestSupport::Constants
  TEST_ROOT_DIR = File.expand_path('../..', __FILE__)
  FIXTURES_DIR = "#{TEST_ROOT_DIR}/fixtures"
  TMP_DIR = File.expand_path('../../../../../../tmp', __FILE__)
  TEST_BUILD_DIR = File.join(TMP_DIR, 'build_dir')
end

