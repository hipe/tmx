require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  ::Skylab::Brazen::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Subject_ = -> do
    Brazen_::Entity
  end
end
