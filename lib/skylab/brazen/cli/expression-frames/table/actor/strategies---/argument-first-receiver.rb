module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategies___::Argument_First_Receiver < Simple_strategy_class_[]

      SUBSCRIPTIONS = [
        :receive_unclassified_argument_stream,
      ]

      def initialize_dup _

        # (across the dup boundary, clear all ivars)

        super
      end

      def receive_unclassified_argument_stream up_st

        o = Brazen_.lib_.plugin::Sessions::Shared_Parse.new
        o.dispatcher = @resources.dispatcher
        o.upstream = up_st
        o.execute
      end
    end
  end
end
