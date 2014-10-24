require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  ::Skylab::Brazen::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  WITH_CLASS_METHOD_ = -> * x_a do
    ent = new
    ok = ent.send :process_iambic_fully, x_a
    ok and ent
  end

  Subject_ = -> do
    Entity_[]
  end
end
