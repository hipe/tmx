require_relative '../test-support'

module Skylab::Face::TestSupport::Plugin

  ::Skylab::Face::TestSupport[ self ]

  include CONSTANTS

  Face = Face
  Plugin_ = Face::Plugin  # we make an exception to the convention here,
    # because of the sheer number of these that exist in our tests

  extend TestSupport::Quickie

end
