module Skylab::Basic

  module String

    class Byte_Upstream_Identifier

      #  :+[#br-019] unified interface for accessing the bytes in a string.

      def initialize s
        @s = s
      end

      # ~ reflection

      def description_under expag
        s = String_.ellipsify( @s ).inspect
        expag.calculate do
          val s
        end
      end

      def shape_symbol
        :string
      end

      # ~ data delivery

      def whole_string
        @s
      end

      def to_simple_line_stream
        String_.line_stream @s
      end
    end
  end
end
