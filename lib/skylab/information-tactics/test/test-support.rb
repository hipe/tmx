require_relative '../core'

::Skylab::InformationTactics::Autoloader_.require_sidesystem :TestSupport

module Skylab::InformationTactics::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    InformationTactics = ::Skylab::InformationTactics
    TestSupport = ::Skylab::TestSupport
  end

  extend ::Skylab::TestSupport::Quickie
end
