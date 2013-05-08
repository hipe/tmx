require_relative '../test-support'

module Skylab::Face::TestSupport::API

  ::Skylab::Face::TestSupport[ API_TestSupport = self ]

  module CONSTANTS
    MetaHell = Face::MetaHell
    MAARS = Face::MAARS
  end

  include CONSTANTS

  Face = Face
  MetaHell = MetaHell
  MAARS = MAARS

  module Sandbox
    extend MAARS
  end

  CONSTANTS::Sandbox = Sandbox
end
