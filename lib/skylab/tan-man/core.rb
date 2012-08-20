require 'skylab/meta-hell/core'

module Skylab
  module TanMan
    TanMan = self # because of lexical scoping. happens in API, need it here
    extend ::Skylab::MetaHell::Autoloader::Autovivifying
  end
end
