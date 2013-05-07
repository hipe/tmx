require_relative '../test-support'

module Skylab::Basic::TestSupport::Field

  ::Skylab::Basic::TestSupport[ Field_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  Basic = Basic

  module CONSTANTS::Sandbox
  end

end
