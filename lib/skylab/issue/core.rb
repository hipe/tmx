require_relative '..'

require 'skylab/face/core'
require 'skylab/meta-hell/core'
require 'skylab/porcelain/core'
require 'skylab/porcelain/all' # wicked old ways


module Skylab::Issue

  Autoloader = ::Skylab::Autoloader
  Face = ::Skylab::Face
  Issue = self # #hiccup
  MetaHell = ::Skylab::MetaHell
  Porcelain_ = ::Skylab::Porcelain # (SL::Issue::Porcelain is ours!)
  PubSub = ::Skylab::PubSub

  extend MetaHell::Autoloader::Autovivifying::Recursive

  module Core
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end
end
