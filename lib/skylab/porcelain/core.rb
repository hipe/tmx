require_relative '..'
require 'skylab/headless/core'
require 'skylab/pub-sub/core'

module Skylab
  module Porcelain
    Headless = ::Skylab::Headless # i win
    MetaHell = ::Skylab::MetaHell
    PubSub   = ::Skylab::PubSub
    extend ::Skylab::MetaHell::Autoloader::Autovivifying
  end
end
