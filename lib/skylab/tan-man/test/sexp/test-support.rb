require_relative '../../core'
require 'skylab/test-support/core'

::Skylab::TanMan::Sexp && nil # load

module ::Skylab::TanMan::Sexp::TestSupport
  extend ::Skylab::MetaHell::Autoloader::Autovivifying
  module Grammars
    # here & now establish that grammars/ is here and not under test-support/
    extend ::Skylab::MetaHell::Autoloader::Autovivifying
    self.dir_path = ::File.expand_path('../grammars', __FILE__)
  end
  TanMan = ::Skylab::TanMan
end
