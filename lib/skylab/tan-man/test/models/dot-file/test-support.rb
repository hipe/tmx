require_relative 'parser/test-support'
require_relative '../../sexp/auto/test-support'

module Skylab::TanMan::Models::DotFile::TestSupport
  def self.extended mod
    mod.extend ::Skylab::TanMan::Sexp::Auto::TestSupport
    mod.extend ::Skylab::TanMan::Models::DotFile::Parser::TestSupport
  end
end
