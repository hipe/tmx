module Skylab
  module Dependency
    module Test
      module Support
        TEST_ROOT_DIR = File.expand_path('../..', __FILE__)
        FIXTURES_DIR = "#{TEST_ROOT_DIR}/fixtures"
        TMP_DIR = "#{TEST_ROOT_DIR}/tmp"
        TEST_BUILD_DIR = File.join(TMP_DIR, 'build_dir')
      end
    end
  end
end
