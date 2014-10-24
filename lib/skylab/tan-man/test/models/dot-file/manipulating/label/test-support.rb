require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Manipulating::Label

  ::Skylab::TanMan::TestSupport::Models::DotFile::Manipulating[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie # run some tests without rspec, just `ruby -w`

  module InstanceMethods

    def module_with_subject_fixtures_node
      TS_
    end
  end
end
