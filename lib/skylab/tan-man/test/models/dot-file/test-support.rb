require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile # 0659-0701
  ::Skylab::TanMan::TestSupport::Models[ DotFile = self ]

  module InstanceMethods
    let( :_input_fixtures_dir_path ) { DotFile::Fixtures.dir_path }
  end
end
