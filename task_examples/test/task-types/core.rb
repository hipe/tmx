require_relative '../test-support'

module Skylab::TaskExamples::TestSupport::Tasks

  ::Skylab::TaskExamples::TestSupport[ TS_ = self ]

  module Constants
    include Home_
  end

  include Constants  # include them here for use in specs

  extend TestSupport_::Quickie  # let's see..

  module InstanceMethods

    include Constants  # some want BUILD_DIR in the i_m's

    def wire! o
      o.context = context
      o.on_all do |e|
        debug_event e if do_debug
        fingers[ e.stream_symbol ] << unstyle( e.text )
      end
    end

    def debug_event e
      dputs [ e.stream_symbol, e.text ].inspect
      NIL_
    end
  end
end
