require_relative '../test-support'

module Skylab::TanMan::TestSupport::Sexp::Prototype # #topic-module

  ::Skylab::TanMan::TestSupport::Sexp[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie  # if you want it, load the spec file with ruby -w

  Home_ = Home_
  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = TestLib_::NEWLINE_

  module Grammars
    Home_::Autoloader_[ self ]
  end

  module InstanceMethods

    def grammars_module
      Grammars
    end
  end
end
