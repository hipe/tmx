module Skylab::Snag

  class Models_::Node

    class Models_::Agnostic_Mutable_Body

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

      def entity_stream_via_model cls

        sym = cls.category_symbol

        to_object_stream_.map_reduce_by do | o |

          if sym == o.category_symbol
            o
          end
        end
      end

      def to_object_stream_
        Callback_::Stream.via_nonsparse_array @_o_a
      end

      alias_method :to_simple_stream_of_objects_, :to_object_stream_

      def append_object o, & oes_p
        @_o_a.push o
        ACHIEVED_
      end

      def prepend_object o, & oes_p
        @_o_a.unshift o
        ACHIEVED_
      end

      def remove_equivalent_object o, & oes_p
        self._FUN
      end
    end
  end
end
