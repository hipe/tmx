require_relative '../core'
require 'skylab/test-support/core'

module Skylab::InformationTactics::TestSupport
  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    InformationTactics = ::Skylab::InformationTactics
  end

  extend ::Skylab::TestSupport::Quickie
end
