require_relative '../test-support'

module Skylab::TanMan::TestSupport::Sexp

  ::Skylab::TanMan::TestSupport[ TS_ = self ]

  include CONSTANTS

  TanMan_ = TanMan_ ; TestLib_ = TestLib_

  module InstanceMethods

    def grammars_module
      TS_::Grammars
    end
  end

  module Grammars
    TanMan_::Autoloader_[ self ]
  end

  class Grammar

  end
end
