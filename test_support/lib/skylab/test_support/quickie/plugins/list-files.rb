module Skylab::TestSupport

  module Quickie

    class Plugins::ListFiles

      def initialize
        o = yield  # microservice
        @_narrator = o.argument_scanner_narrator
        @_shared_datapoint_store = o
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "write to stdout the list of resultant"
        y << "test file(s) then exit"
      end

      def parse_argument_scanner_head feat
        @_narrator.advance_past_match feat.feature_match  # it's a flag - nothing to do
      end

      def release_agent_profile
        Eventpoint_::AgentProfile.define do |o|
          o.must_transition_from_to :files_stream, :finished
        end
      end

      def invoke _
        _sr = @_shared_datapoint_store.release_test_file_path_streamer_
        path_st = _sr.call
        path_st and Responses_::FinalResult[ path_st ]
      end
    end
  end
end
# :#tombstone-A: subtle but pronounced demonstration of improvement
