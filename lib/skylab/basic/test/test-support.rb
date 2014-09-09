require_relative '../core'

module Skylab::Basic

  module TestSupport

    module CONSTANTS
      Basic = Basic_ = Basic
      TestSupport = Autoloader_.require_sidesystem :TestSupport
    end

    include CONSTANTS

    self::TestSupport::Regret[ self ]

    self::TestSupport::Sandbox::Host[ self ]

  end
end
