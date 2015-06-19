module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategies___::Upstream_First_Receiver < Argumentative_strategy_class_[]

      SUBSCRIPTIONS = [
        :arity_for,
        :receive_unsanitized_user_row_upstream
      ]

      PROPERTIES = [
        :argument_arity, :one, :property, :read_rows_from,
      ]

      def initialize_dup _

        # (assume no policy ivars)

        super
      end

      def receive__read_rows_from__argument x

        receive_unsanitized_user_row_upstream x
      end

      def receive_unsanitized_user_row_upstream enum_x

        row_st = Callback_::Polymorphic_Stream.try_convert enum_x
        if row_st

          @resources.receive_sanitized_user_row_upstream row_st
          ACHIEVED_
        else
          raise ::ArgumentError, __say( enum_x )
        end
      end

      def __say enum_x
        "does not look like row upstream: #{ enum_x.class }"
      end
    end
  end
end
