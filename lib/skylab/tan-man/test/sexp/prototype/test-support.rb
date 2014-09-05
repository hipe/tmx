require_relative '../test-support'

module ::Skylab::TanMan::TestSupport::Sexp::Prototype # #topic-module

  ::Skylab::TanMan::TestSupport::Sexp[ TS_ = self ]

  include CONSTANTS # so we can say `TanMan_` in our tests

  extend TestSupport_::Quickie # if you want it, load the spec file with ruby -w

  module Grammars

  end

  module InstanceMethods
    let( :_parser_clients_module ) { Grammars }
  end
end
