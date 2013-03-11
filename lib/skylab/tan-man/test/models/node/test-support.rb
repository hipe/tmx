require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Node

  ::Skylab::TanMan::TestSupport::Models[ Node_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module InstanceMethods

    def collection_class
      TanMan::Models::Node::Collection
    end

    def _input_fixtures_dir_pathname
      Node_TestSupport::Fixtures.dir_pathname
    end
  end
end
