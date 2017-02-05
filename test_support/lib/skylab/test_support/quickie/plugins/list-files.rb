module Skylab::TestSupport

  module Quickie

    class Plugins::ListFiles

      def initialize
      end

      if false
      def initialize adapter
        @fuzzy_flag = adapter.build_fuzzy_flag %w( -list )
        @adapter = adapter
      end

      def opts_moniker
        @fuzzy_flag.some_opts_moniker
      end

      def args_moniker
      end
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "write to stdout the list of resultant"
        y << "test file(s) then exit"
      end

      if false
      def prepare sig
        idx = @fuzzy_flag.any_first_index_in_input sig
        if idx
          sig.nilify_input_element_at_index idx
          sig.rely :CULLED_TEST_FILES
          sig.carry :CULLED_TEST_FILES, :FINISHED
          sig
        end
      end

      def culled_test_files_eventpoint_notify

        _ = @adapter.paystream.method :puts
        @adapter.services.to_test_path_stream.each( & _ )
        NIL_
      end
      end
    end
  end
end
