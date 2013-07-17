module Skylab::TestSupport

  module Quickie

    class Plugins::List

      def initialize svc
        @svc = svc
      end

      def opts_moniker
        SWITCH_
      end

      SWITCH_ = '--list'.freeze

      Match_ = Index_[ SWITCH_ ]

      def args_moniker
      end

      def desc y
        y << "write to stdout the list of resultant"
        y << "test file(s) then exit"
        nil
      end

      def prepare sig
        if (( idx = Match_[ sig.input ] ))
          sig.input[ idx ] = nil
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
