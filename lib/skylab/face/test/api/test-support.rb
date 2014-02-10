require_relative '../test-support'

module Skylab::Face::TestSupport::API

  ::Skylab::Face::TestSupport[ API_TestSupport = self ]

  include CONSTANTS

  Face = Face

  module Sandbox
    Face::Autoloader_[ self ]
  end

end
