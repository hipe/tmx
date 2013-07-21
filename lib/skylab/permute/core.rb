require_relative '..'
require 'skylab/headless/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'

module Skylab::Permute

  Bleeding = ::Skylab::Porcelain::Bleeding
  Headless = ::Skylab::Headless
  Permute = self
  PubSub = ::Skylab::PubSub

  ::Skylab::MetaHell::MAARS[ self ]
end
