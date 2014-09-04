require_relative '../test-support'

module Skylab::TanMan::TestSupport::API

  ::Skylab::TanMan::TestSupport[ TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module InstanceMethods

    def debug!                                 # (aliased to tanman_api_debug!)
      tanman_debug!
      TMPDIR.debug!
      TanMan_::API.debug!
    end
    alias_method :tanman_api_debug!, :debug!
  end
end
