require_relative '../test-support'

module Skylab::TanMan::TestSupport::Sexp

  ::Skylab::TanMan::TestSupport[ TS_ = self ]

  include Constants

  Home_ = Home_
  TestLib_ = TestLib_
  EMPTY_S_ = TestLib_::EMPTY_S_

  module InstanceMethods

    def node_s_a
      @result.nodes
    end

    def grammars_module
      TS_::Grammars
    end
  end

  module Grammars
    Home_::Autoloader_[ self ]
  end

  class Grammar

  end
end
