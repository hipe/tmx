require_relative '../core'

::Skylab::InformationTactics::Autoloader_.require_sidesystem :TestSupport

module Skylab::InformationTactics::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  module Constants
    IT_ = ::Skylab::InformationTactics
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  extend TestSupport_::Quickie
end
