require_relative '..'
require 'skylab/headless/core'
require 'skylab/meta-hell/core'

module Skylab::MyTree

  Headless = ::Skylab::Headless
  Inflection = ::Skylab::Autoloader::Inflection
  MetaHell = ::Skylab::MetaHell
  MyTree = self

  extend MetaHell::Autoloader::Autovivifying::Recursive

  module API
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end
end
