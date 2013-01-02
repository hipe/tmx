require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Association
  ::Skylab::TanMan::TestSupport::Models[ Association_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie



  module InstanceMethods

    def collection_class
      TanMan::Models::Association::Collection
    end

    def _input_fixtures_dir_path
      Association_TestSupport::Fixtures.dir_path
    end

    def lines
      result.unparse.split "\n"
    end
  end
end
