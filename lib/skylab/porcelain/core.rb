require_relative '..'
require 'skylab/headless/core'
require 'skylab/pub-sub/core'

module Skylab
  module Porcelain
    Headless = ::Skylab::Headless # i win
    MAARS    = ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive
    MetaHell = ::Skylab::MetaHell
    PubSub   = ::Skylab::PubSub
    extend MAARS
  end
end
