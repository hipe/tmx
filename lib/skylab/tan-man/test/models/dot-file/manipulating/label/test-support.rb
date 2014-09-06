require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Manipulating::Label

  ::Skylab::TanMan::TestSupport::Models::DotFile::Manipulating[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie # run some tests without rspec, just `ruby -w`

  module InstanceMethods

    def input_fixtures_dir_pathname
      TS_::Fixtures.dir_pathname
    end
  end
end
