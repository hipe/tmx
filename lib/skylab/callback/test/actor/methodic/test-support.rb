require_relative '../test-support'

module Skylab::Callback::TestSupport::Actor::Methodic

  Parent_TS_ = ::Skylab::Callback::TestSupport::Actor

  Parent_TS_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Parent_subject_ = Parent_TS_::Subject_

end
