require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Manipulating::Label

  ::Skylab::TanMan::TestSupport::Models::DotFile::Manipulating[ TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie # run some tests without rspec, just `ruby -w`

  module InstanceMethods
    let :_input_fixtures_dir_pathname do
      TS_::Fixtures.dir_pathname
    end
  end
end
