require_relative '../test-support'

module Skylab::Dependency::TestSupport::Tasks
  ::Skylab::Dependency::TestSupport[ Tasks_TestSupport = self ] # #regret

  module CONSTANTS
    include Dependency
    Dependency::TaskTypes && nil # :/
  end

  include CONSTANTS # include them here for use in specs

  extend TestSupport::Quickie  # let's see..

  module InstanceMethods

    include CONSTANTS # some want BUILD_DIR in the i_m's

    def wire! o
      o.context = context
      o.on_all do |e|
        debug_event e if do_debug
        fingers[ e.stream_name ] << unstylize( e.text )
      end
    end

    def debug_event e
      dputs [ e.stream_name, e.text ].inspect
      nil
    end
  end
end
