require_relative '../../test-support'

module Skylab::MetaHell::TestSupport::Parse::Alternation

  Parent_ = ::Skylab::MetaHell::TestSupport::Parse

  Parent_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Subject_ = -> do
    Parent_::Subject_[]::Functions_::Alternation
  end
end
