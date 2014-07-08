require_relative '..'

require 'skylab/callback/core'
require 'skylab/face/core'

module Skylab::Git

  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader
  Face = ::Skylab::Face
  Git = self
  Git_ = self
  MetaHell = Autoloader_.require_sidesystem :MetaHell

  MAARS = MetaHell::MAARS

  Stdin_, Stdout_, Stderr_ = Face::FUN.const_values_at :Stdin, :Stdout, :Stderr

  module CLI

    def self.new sin, sout, serr
      CLI::Client.new sin, sout, serr
    end

    Autoloader_[ self ]

    module Actions  # #stowaway, because of legacy 'push.rb' artifact
      Autoloader_[ self ]
    end
  end

  MAARS[ self ]

  stowaway :Lib_, 'library-'
end
