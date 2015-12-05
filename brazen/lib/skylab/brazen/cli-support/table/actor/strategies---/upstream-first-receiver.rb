module Skylab::Brazen

  class CLI_Support::Table::Actor

    class Strategies___::Upstream_First_Receiver

      ARGUMENTS = [
        :argument_arity, :one, :property, :read_rows_from,
      ]

      ROLES = [
        :mixed_user_data_upstream_receiver
      ]

      Table_Impl_::Strategy_::Has_arguments[ self ]

      def initialize x
        @parent = x
      end

      def dup( * )

        # our policy is that across a dup boundary, a subject node carries
        # neither its state nor its existence. a new subject node will be
        # created lazily as needed. at writing subject node has no state
        # anyway.

        NIL_
      end

      def receive__read_rows_from__argument x

        _same x
        ACHIEVED_
      end

      def receive_mixed_user_data_upstream enum_x

        _same enum_x
      end

      def _same enum_x

        row_st = Callback_::Polymorphic_Stream.try_convert enum_x
        if row_st

          @parent.receive_sanitized_user_row_upstream row_st
          NIL_
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
