require_relative '../test-support'

module ::Skylab::TanMan::TestSupport::Sexp::Prototype # #topic-module

  ::Skylab::TanMan::TestSupport::Sexp[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie  # if you want it, load the spec file with ruby -w

  TanMan_ = TanMan_

  module Grammars

    define_singleton_method :const_missing,
      TanMan_::TestSupport::Sexp::GRAMMAR_MODULE_CONST_MISSING_METHOD_

    TanMan_::Autoloader_[ self ]
  end

  module InstanceMethods

    def parser_clients_module
      Grammars
    end
  end
end
