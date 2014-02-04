require_relative '../test-support'

module Skylab::Callback::TestSupport::Bundles

  ::Skylab::Callback::TestSupport[ TS__ = self ]

  include CONSTANTS

  Callback = Callback ; TestSupport = TestSupport

  extend TestSupport::Quickie

  module InstanceMethods

    def any_relevant_debug_IO
      do_debug && debug_IO
    end

    def debug!
      @do_debug = true ; nil
    end
    attr_reader :do_debug

    def debug_IO
      TestSupport::Stderr_[]
    end
  end
end
