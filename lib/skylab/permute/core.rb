require_relative '..'
require 'skylab/meta-hell/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'


module Skylab::Permute

  Bleeding = ::Skylab::Porcelain::Bleeding
  Permute = self
  Porcelain = ::Skylab::Porcelain



  extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive
end
