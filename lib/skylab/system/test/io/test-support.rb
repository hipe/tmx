require_relative '../test-support'

module Skylab::Headless::TestSupport::IO

  ::Skylab::Headless::TestSupport[ self ]

  include Constants

  Headless_ = Headless_

  Constants::TestLib_ = TestLib_

end
