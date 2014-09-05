require_relative '../test-support'

module Skylab::TanMan::TestSupport::API

  ::Skylab::TanMan::TestSupport[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  module InstanceMethods

    def debug!
      super
    end
  end
end
