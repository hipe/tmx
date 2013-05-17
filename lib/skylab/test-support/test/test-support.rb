require_relative '../core'

module Skylab::TestSupport::TestSupport # haha yay

  ::Skylab::TestSupport::Regret[ TestSupport_TestSupport = self ]

  module CONSTANTS
    TestSupport = ::Skylab::TestSupport # this might be really asking for it
  end

  include CONSTANTS # see note above about really asking for it

end
