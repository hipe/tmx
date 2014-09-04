require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Association

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module InstanceMethods

    def collection_class
      TanMan_::Models::Association::Collection
    end

    def _input_fixtures_dir_pathname
      TS_::Fixtures.dir_pathname
    end

    def lines
      result.unparse.split "\n"
    end
  end
end
