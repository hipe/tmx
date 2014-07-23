require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  ::Skylab::Brazen::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  WITH_CLASS_METHOD_ = -> * x_a do
    new.send :process_iambic_fully, x_a
  end

  Subject_ = -> do
    Brazen_::Entity
  end
end
