require_relative '../test-support'

module Skylab::TanMan::TestSupport::API
  ::Skylab::TanMan::TestSupport[ API_TestSupport = self ]

  module InstanceMethods
    def debug!                                 # (aliased to tanman_api_debug!)
      tanman_debug!
      TMPDIR.debug!
      TanMan::API.debug = $stderr # ok here i hope
    end
    alias_method :tanman_api_debug!, :debug!
  end
end
