require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Klass
  (Parent_ = ::Skylab::MetaHell::TestSupport)[ self ] # #ts-002, regret

  CONSTANTS = Parent_::CONSTANTS

end
