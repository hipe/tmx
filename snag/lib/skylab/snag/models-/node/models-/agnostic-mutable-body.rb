module Skylab::Snag

  class Models_::Node

    class Models_::Agnostic_Mutable_Body < Common_Body_

      def initialize
        @_o_a = []
      end

      def prepend_component_ qk, & _p
        o = qk.value
        @_o_a.unshift o
        o
      end

      def append_component_ qk, & _p
        o = qk.value
        @_o_a.push o
        o
      end

      # remove component is etc

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

          _row = Here_::ExpressionAdapters::ByteStream::Models_::Substring.
            new( 0, s.length, s )  # :+#visibility-breach

          Common_::Stream.via_item _row
        else
          Common_::THE_EMPTY_STREAM
        end
      end

      def to_object_stream_
        Stream_[ @_o_a ]
      end

      def r_
        0 ... 1
      end

      def is_mutable
        true
      end

      def modality_const
        NIL_
      end
    end
  end
end
