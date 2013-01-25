require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Formal
  ::Skylab::MetaHell::TestSupport[ Formal_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie
end
