require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Association

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def collection_class
      TanMan_::Models::Association::Collection
    end

    def module_with_subject_fixtures_node
      TS_
    end

    def lines
      result.unparse.split NEWLINE_
    end
  end
end
