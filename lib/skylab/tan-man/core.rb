require_relative '..' # skylab.rb
require 'skylab/headless/core'
require 'skylab/meta-hell/core'

module Skylab
  module TanMan
    Headless = ::Skylab::Headless
    MetaHell = ::Skylab::MetaHell
    TanMan = self # because of #sl-107
    extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive
  end
end
