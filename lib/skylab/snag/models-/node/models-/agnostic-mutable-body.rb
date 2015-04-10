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

        sym = cls.business_category_symbol

        to_object_stream_.map_reduce_by do | o |

          if sym == o.business_category_symbol
            o
          end
        end
      end

      def to_object_stream_
        Callback_::Stream.via_nonsparse_array @_o_a
      end

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
