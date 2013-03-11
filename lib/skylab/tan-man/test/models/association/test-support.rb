require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Association
  ::Skylab::TanMan::TestSupport::Models[ Association_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie



  module InstanceMethods

    def collection_class
      TanMan::Models::Association::Collection
    end

    def _input_fixtures_dir_pathname
      Association_TestSupport::Fixtures.dir_pathname
    end

    def lines
      result.unparse.split "\n"
    end
  end
end
