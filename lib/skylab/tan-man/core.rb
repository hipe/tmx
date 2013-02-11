require_relative '..' # skylab.rb
require 'skylab/porcelain/core' # attr definer, table

module Skylab
  module TanMan
    Autoloader   = ::Skylab::Autoloader
    Bleeding     = ::Skylab::Porcelain::Bleeding
    Headless     = ::Skylab::Headless
    MetaHell     = ::Skylab::MetaHell
    PubSub       = ::Skylab::PubSub
    TanMan       = self #sl-107 (pattern)

    extend MetaHell::Autoloader::Autovivifying::Recursive
  end

  module TanMan::Core
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end
end
