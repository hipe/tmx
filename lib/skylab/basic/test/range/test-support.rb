require_relative '../test-support'

module Skylab::Basic::TestSupport::Range

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Subject_ = -> do
    Basic_::Range
  end
end
