module Skylab::TestSupport

  module Quickie

    class Plugins::RunFiles

      def initialize
        o = yield
        @listener = o.listener
        @_shared_datapoint_store = o
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "run the tests in the files"
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
        if prepare_
          __call_the_runtime
        end
      end

      def prepare_
        ok = true
        ok &&= __resolve_path_stream
        ok &&= __resolve_injected_client
        ok &&= __resolve_callable_runtime
        ok
      end

      def __call_the_runtime

        # (horribly mimicked by #quickie-spot-2-2)

        _plus_these = flush_optional_arguments_

        _ic = remove_instance_variable :@injected_client

        @runtime.call_the_quickie_runtime_(
          * _plus_these,
          :injected_client, _ic,
          :load_tests_by, method( :load_the_test_files_ ),
          & @listener
        )
        # (result of above is stats object)
        NIL
      end

      def flush_optional_arguments_
        plus_these = nil
        s_a = @_shared_datapoint_store.release_any_unparsed_tags__
        if s_a
          plus_these ||= []
          s_a.each do |s|
            plus_these.push :tag, s
          end
        end
        plus_these
      end

      def load_the_test_files_ _runtime
        st = remove_instance_variable :@__path_stream
        count = 0
        begin
          path = st.gets
          path || break
          count += 1
          load path  #testpoint 2x
          redo
        end while above
        count.nonzero? and __express_count count
        NIL
      end

      def __express_count count
        @listener.call :info, :expression, :number_of_files do |y|
          y << "(#{ count } file#{ 's' if 1 != count } loaded)"
        end
        NIL
      end

      def __resolve_callable_runtime
        @runtime = __quickie_runtime
        if @runtime.quickie_service_is_running__
          __when_service_is_already_running
          remove_instance_variable :@runtime
          ::Kernel._A
        else
          ACHIEVED_
        end
      end

      def __when_service_is_already_running
        self._COVER_ME
        # near "creating non-daemonized instance" before the overhaul
      end

      def __quickie_runtime  # #testpoint
        Here_.runtime_
      end

      def __resolve_injected_client
        ok = true
        p = @listener
        ok &&= _store( :@injected_client, p[ :resource, :injected_client_resource ] )
        ok
      end

      def __resolve_path_stream
        _sr = @_shared_datapoint_store.release_test_file_path_streamer_
        _store :@__path_stream, _sr.call
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==

      attr_reader(
        :injected_client,
        :listener,
        :runtime,
      )

      # ==
    end
  end
end
# :#tombstone-A: old, complex eventpoint graph
