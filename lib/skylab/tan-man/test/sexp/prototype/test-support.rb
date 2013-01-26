require_relative '../test-support'

module ::Skylab::TanMan::TestSupport::Sexp::Prototype # #topic-module
  ::Skylab::TanMan::TestSupport::Sexp[ Prototype_TestSupport = self ]

  include CONSTANTS # so we can say `TanMan` in our tests

  extend TestSupport::Quickie # if you want it, load the spec file with ruby -w

  module Grammars
    extend ::Skylab::TanMan::TestSupport::Sexp::Grammar::Boxxy
  end

  module InstanceMethods
    let( :_parser_clients_module ) { Grammars }
  end
end
