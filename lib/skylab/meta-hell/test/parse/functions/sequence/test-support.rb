require_relative '../../test-support'

module Skylab::MetaHell::TestSupport::Parse::Functions::Sequence

  ::Skylab::MetaHell::TestSupport::Parse::Functions[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Subject_ = -> do
    Parse_lib_[]::Functions_::Sequence
  end
end
