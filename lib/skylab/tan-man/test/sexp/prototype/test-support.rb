require_relative '../test-support'

module ::Skylab::TanMan::TestSupport::Sexp::Prototype # #topic-module

  ::Skylab::TanMan::TestSupport::Sexp[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie  # if you want it, load the spec file with ruby -w

  TanMan_ = TanMan_

  NEWLINE_ = NEWLINE_

  module Grammars
    TanMan_::Autoloader_[ self ]
  end

  module InstanceMethods

    def grammars_module
      Grammars
    end
  end
end
