module Skylab::TestSupport

  module Quickie

    class Plugins::ListFiles

      def initialize
        @_waypoint_datapoint_store = yield
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "write to stdout the list of resultant"
        y << "test file(s) then exit"
      end

      def parse_argument_scanner_head
        ACHIEVED_  # nothing to do. it's a flag
      end

      def release_agent_profile
        Eventpoint_::AgentProfile.define do |o|
          o.can_transition_from_to :files_stream, :finished
        end
      end

      def invoke _
        _sr = @_waypoint_datapoint_store.release_test_file_path_streamer__
        path_st = _sr.call
        path_st and Responses_::FinalResult[ path_st ]
      end
    end
  end
end
# :#tombstone-A: subtle but pronounced demonstration of improvement
