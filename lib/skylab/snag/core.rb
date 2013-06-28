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

  module Core
    extend MetaHell::MAARS
  end

  IDENTITY_ = -> x { x }

  extend MetaHell::MAARS
end
