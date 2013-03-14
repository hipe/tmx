require_relative '..'

require 'skylab/headless/core'
require 'skylab/meta-hell/core'
require 'skylab/porcelain/core'


module Skylab::Snag

  Autoloader = ::Skylab::Autoloader
  Headless = ::Skylab::Headless
  Snag = self # #hiccup
  MetaHell = ::Skylab::MetaHell
  Porcelain = ::Skylab::Porcelain
  PubSub = ::Skylab::PubSub

  extend MetaHell::Autoloader::Autovivifying::Recursive

  module Core
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end
end
