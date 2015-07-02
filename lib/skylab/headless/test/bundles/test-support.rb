require_relative '../test-support'

module Skylab::Headless::TestSupport::Bundles

  ::Skylab::Headless::TestSupport[ self ]

  module Delegating

    ::Skylab::Headless::TestSupport::Bundles[ self ]

    include Constants

    extend TestSupport_::Quickie

    Home_ = Home_
  end
end
