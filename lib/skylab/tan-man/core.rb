require_relative '..' # skylab.rb
require 'skylab/face/core'
require 'skylab/headless/core'
require 'skylab/meta-hell/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'

module Skylab
  module TanMan
    Autoloader = ::Skylab::Autoloader
    Bleeding   = ::Skylab::Porcelain::Bleeding
    Face       = ::Skylab::Face
    Headless   = ::Skylab::Headless
    MetaHell   = ::Skylab::MetaHell
    Porcelain  = ::Skylab::Porcelain
    PubSub     = ::Skylab::PubSub
    TanMan     = self #sl-107 (pattern)

    extend MetaHell::Autoloader::Autovivifying::Recursive
  end

  module TanMan::Core
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end
end
