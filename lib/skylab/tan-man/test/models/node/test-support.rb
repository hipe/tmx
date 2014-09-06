require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Node

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  module InstanceMethods

    def collection_class
      TanMan_::Models::Node::Collection
    end

    def input_fixtures_dir_pathname
      TS_::Fixtures.dir_pathname
    end
  end
end
