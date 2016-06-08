require_relative '../test-support'

module Skylab::Common::TestSupport::Bundles

  ::Skylab::Common::TestSupport[ TS__ = self ]

  include Constants

  Home_ = Home_

  extend TestSupport_::Quickie

  TestSupport_ = TestSupport_

  module InstanceMethods

    def any_relevant_debug_IO
      do_debug && debug_IO
    end
  end
end
