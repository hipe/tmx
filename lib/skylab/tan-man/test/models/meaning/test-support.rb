require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Meaning

  Parent_ = ::Skylab::TanMan::TestSupport::Models

  Parent_[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  # Home_::Models::Meaning.const_get :Graph, false # jerks

end
