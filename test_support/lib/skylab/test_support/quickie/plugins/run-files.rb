module Skylab::TestSupport

  module Quickie

    class Plugins::RunFiles

      def initialize
        o = yield
        @_listener = o.listener
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
        ok = true
        ok &&= __resolve_path_stream
        ok &&= __resolve_injected_client
        ok &&= __resolve_callable_runtime
        ok && __call_the_runtime
        NIL  # no tangible result for now
      end

      def __call_the_runtime

        _ic = remove_instance_variable :@__injected_client

        _stats = @_runtime.call(
          :injected_client, _ic,
          :load_tests_by, method( :__load_the_test_files ),
          & @_listener
        )

        NIL
      end

      def __load_the_test_files _runtime
        st = remove_instance_variable :@__path_stream
        count = 0  # ignored
        begin
          path = st.gets
          path || break
          count += 1
          load path  #testpoint
          redo
        end while above
        count.nonzero? and __express_count count
        NIL
      end

      def __express_count count
        @_listener.call :info, :expression, :number_of_files do |y|
          y << "(ran tests in #{ count } file#{ 's' if 1 != count })"
        end
        NIL
      end

      def __resolve_callable_runtime
        @_runtime = __quickie_runtime
        if @_runtime.quickie_service_is_running__
          __when_service_is_already_running
          remove_instance_variable :@_runtime
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
        p = @_listener
        ok &&= _store( :@__injected_client, p[ :resource, :injected_client_resource ] )
        ok
      end

      def __resolve_path_stream
        _sr = @_shared_datapoint_store.release_test_file_path_streamer_
        _store :@__path_stream, _sr.call
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==
      # ==
    end
  end
end
# :#tombstone-A: old, complex eventpoint graph
