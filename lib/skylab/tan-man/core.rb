require_relative '..' # skylab.rb
require 'skylab/meta-hell/core'

module Skylab
  module TanMan
    TanMan = self # because of #sl-107
    extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive
  end
end
