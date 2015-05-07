require_relative '../../test-support'

module Skylab::MetaHell::TestSupport::Parse::Functions::Serial_Optionals

  ::Skylab::MetaHell::TestSupport::Parse::Functions[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  LIB_ = LIB_

  MetaHell_ = MetaHell_

  Parse_lib_ = Parse_lib_

  SPACE_ = ' '.freeze

  Subject_ = -> do
    Parse_lib_[]::Functions_::Serial_Optionals
  end
end
