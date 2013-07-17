module Skylab::TestSupport

  module Quickie

    class Plugins::Cover

      def initialize svc
        @svc = svc
      end

      def opts_moniker
        SWITCH_
      end

      SWITCH_ = '--cover'.freeze

      Match_ = Index_[ SWITCH_ ]

      def args_moniker
      end

      def desc y
        y << "run the coverage service for the"
        y << "subtree inferred by the test files"
        nil
      end

      def prepare sig
        if (( idx = Match_[ sig.input ] ))
          sig.input[ idx ] = nil
          sig.rely :BEFORE_EXECUTION
          sig
        end
      end

      def before_execution_eventpoint_notify
        Quickie::Plugins::Cover::Worker_.new( @svc ).execute
      end
    end
  end
end
