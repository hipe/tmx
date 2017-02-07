module Skylab::TestSupport

  module Quickie

    class Plugins::DocOnly

      # (perhaps no equivalent in rspec :[#009.F])

      def initialize
        @_shared_datapoint_store = yield
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "does not run tests but otherwise looks similar to our"
        y << "default output format (`--format documentation` in"
        y << "rspec). useful for seeing which examples match certain"
        y << "tags (etc) regardless of what state the tests are in."
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

        # (there's a whole discussion of this dodgey dependence of one
        # plugin on another at [#006.B]. here we are assuming that
        # given the eventpoint graph, if the subject plugin is activated
        # then the remote plugin is not, so in the below we are in effect
        # constructing an instance of the remote plugin for our own use..)

        @_worker = @_shared_datapoint_store.DEREFERENCE_PLUGIN :run_files

        if @_worker.prepare_
          __call_the_runtime
        end
      end

      def __call_the_runtime

        # (horribly mimicking #quickie-spot-2-2)

        o = remove_instance_variable :@_worker
        _ic = o.injected_client

        _EEK = -> rt do
          # hi.
          _ = o.load_the_test_files_ rt
          _  # #todo
        end

        _plus_these = o.flush_optional_arguments_

        o.runtime.call_the_quickie_runtime_(
          :do_documentation_only,
          * _plus_these,
          :statistics_class, DocumentingStats___,
          :injected_client, _ic,
          :load_tests_by, _EEK,
          & o.listener
        )
        # (result of above is stats obect)
        NIL
      end

      # ==

      class DocumentingStats___

        def initialize client
          @_example_count = 0
          @_pending_count = 0
          @__time_one = ::Time.now
        end

        def tick_pending
          @_pending_count += 1
        end

        def tick_documentation_only
          @_example_count += 1
        end

        def close
          @elapsed_time = ::Time.now - remove_instance_variable( :@__time_one )
          NIL
        end

        # -- read

        def tempurature_between_zero_and_ten_inclusive
          @_pending_count.zero? ? 0 : 4  # cool or warm, never hot
        end

        def main_count_is_zero
          @_example_count.zero?
        end

        def to_qualified_datapoint_stream
          a = []
          a.push QualifiedDatapoint_.new( @_example_count, "example seen (not run)" )
          a.push QualifiedDatapoint_.new( @_pending_count, "pending", false, false )
          Stream_[ a ]
        end

        attr_reader :elapsed_time
      end

      # ==
    end
  end
end
# #born to help test something, but also because it's potentially useful
