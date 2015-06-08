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

      def to_business_row_stream_

        # meh for now..

        st = to_object_stream_
        o = st.gets
        if o

          s = o.express_under :Event

          begin
            o = st.gets
            o or break
            s << "#{ SPACE_ }#{ o.express_under :Event }"
            redo
          end while nil

          _row = Node_::Expression_Adapters::Byte_Stream::Models_::Substring.
            new( 0, s.length, s )  # :+#visibility-breach

          Callback_::Stream.via_item _row
        else
          Callback_::Stream.the_empty_stream
        end
      end

      def to_object_stream_
        Callback_::Stream.via_nonsparse_array @_o_a
      end

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
