require_relative '../../test-support'

module Skylab::MetaHell::TestSupport::Parse::Functions::Spending_Pool

  ::Skylab::MetaHell::TestSupport::Parse::Functions[ self ]

  include Constants

  extend TestSupport_::Quickie

  Parse_lib_ = Parse_lib_

  Subject_ = -> do
    Parse_lib_[]::Functions_::Spending_Pool
  end

end
