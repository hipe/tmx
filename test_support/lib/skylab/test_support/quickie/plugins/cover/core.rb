module Skylab::TestSupport

  module Quickie

    class Plugins::Cover

      def initialize
      end

      if false
      def initialize adapter

        @fuzzy_flag = adapter.build_fuzzy_flag %w( -cover )
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
        y << "run the coverage service for the"
        y << "subtree inferred by the test files"
      end

      if false
      def prepare sig
        idx = @fuzzy_flag.any_first_index_in_input sig
        if idx
          sig.nilify_input_element_at_index idx
          sig.rely :BEFORE_EXECUTION
          sig
        end
      end

      def before_execution_eventpoint_notify
        Here_::Plugins::Cover::Worker__.new( @adapter ).execute
      end
      end
    end
  end
end
