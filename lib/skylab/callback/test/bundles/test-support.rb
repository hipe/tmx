require_relative '../test-support'

module Skylab::Callback::TestSupport::Bundles

  ::Skylab::Callback::TestSupport[ TS__ = self ]

  include Constants

  Callback_ = Callback_

  Callback_::Lib_::Quickie[ self ]

  module InstanceMethods

    def any_relevant_debug_IO
      do_debug && debug_IO
    end
  end
end
