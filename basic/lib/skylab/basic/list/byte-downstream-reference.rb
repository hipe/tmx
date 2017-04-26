module Skylab::Basic

  module List

    class ByteDownstreamReference

      # #[#ba-062.2] comport to a semi-unified interface for writing bytes into
      # this "waypoint", when the waypoint is a mutable array presumably
      # with lines in it.

      # shh don't tell this is only ever used in testing to mock a
      # filesystem IO handle opened for writing. we clear the array
      # on first write.

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
        "«output stream»"  # :+#guillemets
      end

      def shape_symbol
        :line_list
      end

      # ~ data acceptance exposures

      def to_minimal_yielder_for_receiving_lines  # :+[#046]
        @s_a.clear
        @s_a
      end
    end
  end
end
