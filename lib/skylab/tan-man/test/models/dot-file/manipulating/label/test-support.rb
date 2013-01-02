require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Manipulating::Label
  ::Skylab::TanMan::TestSupport::Models::DotFile::Manipulating[ self ]
   Label_TestSupport = self

  include CONSTANTS

  extend TestSupport::Quickie # run some tests without rspec, just `ruby -w`

  module InstanceMethods
    let :_input_fixtures_dir_path do
      Label_TestSupport::Fixtures.dir_path
    end
  end
end
