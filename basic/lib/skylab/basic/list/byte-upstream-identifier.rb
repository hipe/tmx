module Skylab::Basic

  module List

    class Byte_Upstream_Identifier

      # a :+[#br-019] unified interface for accessing the bytes of an
      # array of strings representing the lines in a file.

      # shh don't tell we only ever use this to mock an IO stream opened
      # only for reading (and perhaps convert it to one only for writing)

      def initialize s_a
        @s_a = s_a
      end

      # ~ reflection

      def is_same_waypoint_as x
        :line_list == x.shape_symbol && @s_a.object_id == x.the_array__.object_id
      end

      protected def the_array__
        @s_a
      end

      def description_under expag
        "«input stream»"  # :+#guillemets
      end

      def shape_symbol
        :line_list
      end

      def modality_const
        :Byte_Stream
      end

      # ~ data delivery

      def whole_string
        @s_a * EMPTY_S_
      end

      def to_simple_line_stream
        Common_::Stream.via_nonsparse_array @s_a
      end

      # ~ fun etc.

      def to_byte_downstream_identifier
        List_::Byte_Downstream_Identifier.new @s_a
      end
    end
  end
end
