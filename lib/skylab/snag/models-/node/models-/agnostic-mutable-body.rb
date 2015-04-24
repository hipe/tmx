module Skylab::Snag

  class Models_::Node

    class Models_::Agnostic_Mutable_Body < Common_Body_

      def initialize
        @_o_a = []
      end

      def is_mutable
        true
      end

      def modality_const
        NIL_
      end

      def r_
        0 ... 1
      end

      def to_object_stream_
        Callback_::Stream.via_nonsparse_array @_o_a
      end

      alias_method :to_simple_stream_of_objects_, :to_object_stream_

      def __append__object_for_mutation_session o, & oes_p
        @_o_a.push o
        ACHIEVED_
      end

      def __prepend__object_for_mutation_session o, & oes_p
        @_o_a.unshift o
        ACHIEVED_
      end

      def remove_equivalent_object o, & oes_p
        self._FUN
      end
    end
  end
end
