require_relative '../test-support'

module Skylab::Dependency::TestSupport::Tasks
  ::Skylab::Dependency::TestSupport[ Tasks_TestSupport = self ] # #regret

  module CONSTANTS
    include Dependency
    Dependency::TaskTypes && nil # :/
  end

  include CONSTANTS # include them here for use in specs

  module InstanceMethods
    include CONSTANTS # some want BUILD_DIR in the i_m's
    def wire! o
      o.context = context
      o.on_all do |e|
        self.debug and $stderr.puts [e.stream_name, e.message].inspect
        fingers[e.stream_name].push unstylize( e.to_s ) #  soft version - no style ok
      end
    end
  end
end
