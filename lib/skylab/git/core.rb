require_relative '..'

require 'skylab/callback/core'
require 'skylab/face/core'

module Skylab::Git

  Autoloader_ = ::Skylab::Callback::Autoloader
  Face = ::Skylab::Face
  Git = self
  MetaHell = ::Skylab::MetaHell

  MAARS = MetaHell::MAARS

  Stdin_, Stdout_, Stderr_ = Face::FUN.const_values_at :Stdin, :Stdout, :Stderr

  module CLI

    def self.new sin, sout, serr
      CLI::Client.new sin, sout, serr
    end

    Autoloader_[ self ]
  end

  MAARS[ self ]
end
