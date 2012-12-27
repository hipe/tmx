require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Meaning
  ::Skylab::TanMan::TestSupport::Models::DotFile[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  TanMan::Models::DotFile::Meaning.const_get :Graph, false # jerks

end
