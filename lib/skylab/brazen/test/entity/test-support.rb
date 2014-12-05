require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  ::Skylab::Brazen::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  WITH_CLASS_METHOD_ = -> * x_a do
    ok = nil
    ent = new do
      ok = process_iambic_fully x_a
    end
    ok and ent
  end

  Subject_ = -> do
    Entity_[]
  end
end
