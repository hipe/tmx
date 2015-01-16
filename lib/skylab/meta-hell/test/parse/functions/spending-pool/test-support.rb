require_relative '../../test-support'

module Skylab::MetaHell::TestSupport::Parse::Spending_Pool

  Parent_ = ::Skylab::MetaHell::TestSupport::Parse

  Parent_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Parse_lib_ = -> do
    Parent_::Subject_[]
  end

  Subject_ = -> do
    Parent_::Subject_[]::Functions_::Spending_Pool
  end

end
