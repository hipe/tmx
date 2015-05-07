require_relative '../../test-support'

module Skylab::MetaHell::TestSupport::Parse::Functions::Alternation

  ::Skylab::MetaHell::TestSupport::Parse::Functions[ self ]

  include Constants

  extend TestSupport_::Quickie

  Subject_ = -> do
    Parse_lib_[]::Functions_::Alternation
  end
end
