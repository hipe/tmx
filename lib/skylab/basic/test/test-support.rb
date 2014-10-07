require_relative '../core'

module Skylab::Basic

  module TestSupport

    module CONSTANTS
      Basic_ = ::Skylab::Basic
      TestSupport_ = Autoloader_.require_sidesystem :TestSupport
    end

    include CONSTANTS

    TestSupport_::Regret[ self ]

    TestSupport_::Sandbox::Host[ self ]

  end
end
