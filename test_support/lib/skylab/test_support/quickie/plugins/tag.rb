module Skylab::TestSupport

  module Quickie

    class Plugins::Tag

      def initialize
        o = yield
        @_shared_datapoint_store = o
        @_unparsed_tag_expressions = []
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "passes through to the test runner."
      end

      def parse_argument_scanner_head
        x = @_shared_datapoint_store.argument_scanner.parse_trueish_primary_value
        if x
          @_unparsed_tag_expressions.push x ; ACHIEVED_
        end
      end

      def release_agent_profile
        send ( @_once ||= :__release_agent_profile_once )
      end

      def __release_agent_profile_once
        @_once = :__nothing
        Eventpoint_::AgentProfile.define do |o|
          o.must_transition_from_to :files_stream, :files_stream
        end
      end

      def __nothing
        # subsequent occurrences in the argument array are all processed
        # by the same plugin instance as a single invocation
        NOTHING_
      end

      def invoke _

        _x_a = remove_instance_variable :@_unparsed_tag_expressions

        Responses_::Datapoint[ _x_a, :unparsed_tag_expressions ]
      end
    end
  end
end
# #history: mostly full rewrite
