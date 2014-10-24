require_relative '../test-support'

module Skylab::Headless::TestSupport::System

  ::Skylab::Headless::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Headless_ = Headless_

  module InstanceMethods

    def subject
      Headless_.system
    end
  end
end
