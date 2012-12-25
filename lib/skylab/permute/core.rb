require_relative '..'
require 'skylab/headless/core'
require 'skylab/meta-hell/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'


module Skylab::Permute

  Bleeding = ::Skylab::Porcelain::Bleeding
  Headless = ::Skylab::Headless
  Permute = self
  Porcelain = ::Skylab::Porcelain



  extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive
end
