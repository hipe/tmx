require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Face::TestSupport

  module CONSTANTS
    Face = ::Skylab::Face
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  TestSupport::Regret[ self ]

  stowaway :CLI, 'cli/test-support'  # [#mh-030] for [#045]

  TestSupport::Sandbox::Host[ self ]

end
