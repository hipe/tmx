require_relative '../test-support'

module Skylab::Basic::TestSupport::Tree

  ::Skylab::Basic::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Subject_ = -> do
    Basic_::Tree
  end
end
