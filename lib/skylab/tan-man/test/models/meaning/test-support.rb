require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Meaning

  ::Skylab::TanMan::TestSupport::Models[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  # TanMan_::Models::Meaning.const_get :Graph, false # jerks

end
