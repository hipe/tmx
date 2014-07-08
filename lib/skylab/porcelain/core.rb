require_relative '..'

require 'skylab/callback/core'

module Skylab

  module Porcelain

    Callback = ::Skylab::Callback
    Autoloader_ = Callback::Autoloader
    o = Autoloader_.method :require_sidesystem

    Face = o[ :Face ]
    Headless = o[ :Headless ]
    MetaHell = o[ :MetaHell ]
    Porcelain = self
    Porcelain_ = self

    # headless in porcelain yes. headles trumps porcelain.

    MAARS = MetaHell::MAARS

    MAARS[ self ]

    stowaway :Lib_, 'library-'
  end
end
