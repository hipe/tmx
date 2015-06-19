module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategies___::Row_First_Receiver < Argumentative_strategy_class_[]

      SUBSCRIPTIONS = [
        :receive_downstream_element,
        :receive_user_row,
        :receive_table,
      ]

      # facilitate the minimum necessary to display user rows with default
      # styling. as well, is inverted and serves as a buffer between a
      # pub-sub abstraction layer and our strategy pattern.

      def initialize pu_id, rsc, & x_p

        o = Strategies___.new
        o.add_initial_assignment(
          :downstream_receiver,
          :row_receiver,
          :table_receiver,
          Me_the_Strategy_::Models__::Content_Matrix.new
        )
        @_strategies = o
        super
      end

      Strategies___ = Brazen_.lib_.plugin::Strategies.new(
        :downstream_receiver,
        :row_receiver,
        :table_receiver,
      )

      def initialize_dup _

        stra = remove_instance_variable :@_strategies
        super
        @_strategies = stra.dup  # NOTE this carries over and
          # deep dups ONLY the initial assignments created above.

      end

      def receive_downstream_element ctx

        @_strategies.downstream_receiver.receive_downstream_element ctx
      end

      def replace_downstream_receiver stgy

        @_strategies.replace :downstream_receiver, stgy
      end

      def receive_user_row user_row_x

        @_strategies.row_receiver.receive_user_row user_row_x
      end

      def replace_row_receiver_by & x_p

        @_strategies.replace_by :row_receiver, & x_p
      end

      def receive_table

        @_strategies.table_receiver.receive_table
      end

      def replace_table_receiver stgy

        @_strategies.replace :table_receiver, stgy
      end

      Me_the_Strategy_ = self
    end
  end
end
