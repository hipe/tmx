module Skylab::TestSupport

  module Quickie

    class Plugins::Cover

      def initialize svc
        @fuzzy_flag = svc.build_fuzzy_flag %w( -cover )
        @svc = svc ; nil
      end

      def opts_moniker
        @fuzzy_flag.some_opts_moniker
      end

      def args_moniker
      end

      def desc y
        y << "run the coverage service for the"
        y << "subtree inferred by the test files"
        nil
      end

      def prepare sig
        idx = @fuzzy_flag.any_first_index_in_input sig
        if idx
          sig.nilify_input_element_at_index idx
          sig.rely :BEFORE_EXECUTION
          sig
        end
      end

      def before_execution_eventpoint_notify
        Quickie::Plugins::Cover::Worker__.new( @svc ).execute
      end
    end
  end
end
