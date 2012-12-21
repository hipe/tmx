require_relative '../test-support'

module ::Skylab::TanMan::TestSupport::Sexp::Prototype # #topic-module
  ::Skylab::TanMan::TestSupport::Sexp[ self ]

  module Grammars
    extend ::Skylab::TanMan::TestSupport::Sexp::Grammar::Boxxy
  end

  module InstanceMethods
    let( :_parser_clients_module ) { Grammars }
  end
end
