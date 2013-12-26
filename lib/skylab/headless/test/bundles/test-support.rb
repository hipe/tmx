require_relative '../test-support'

module Skylab::Headless::TestSupport::Bundles

  ::Skylab::Headless::TestSupport[ self ]

  module Delegating

    ::Skylab::Headless::TestSupport::Bundles[ self ]

    include CONSTANTS

    extend TestSupport::Quickie

    Headless = Headless
  end
end
