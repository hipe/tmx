module Skylab::TestSupport

  module Quickie

    class Plugins::List

      def initialize svc
        @fuzzy_flag = svc.build_fuzzy_flag %w( -list )
        @svc = svc
      end

      def opts_moniker
        @fuzzy_flag.some_opts_moniker
      end

      def args_moniker
      end

      def desc y
        y << "write to stdout the list of resultant"
        y << "test file(s) then exit"
        nil
      end

      def prepare sig
        idx = @fuzzy_flag.any_first_index_in_input sig
        if idx
          sig.nilify_input_element_at_index idx
          sig.rely :TEST_FILES
          sig.carry :TEST_FILES, :FINISHED
          sig
        end
      end

      def test_files_eventpoint_notify
        ps = @svc.paystream
        @svc.get_test_path_a.each( & ps.method( :puts ) )
        nil
      end
    end
  end
end
