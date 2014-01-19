require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::Slake

  MetaHell = ::Skylab::MetaHell
  Slake = ::Skylab::Slake

  ::Skylab::Autoloader[ self ]

  module Lib_  # :+[#su-001]
    StringIO = -> do
      require 'stringio' ; ::StringIO
    end
  end
end
