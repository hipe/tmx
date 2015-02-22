module Skylab::Basic

  module String

    class Byte_Upstream_Identifier < ::Class.new

      #  :+[#br-019] unified interface for accessing the bytes in a string.

      # ~ data delivery

      def whole_string
        @s
      end

      def to_simple_line_stream
        String_.line_stream @s
      end

      Superclass = superclass

      class Superclass

        def initialize s
          @s = s
        end

        # ~ reflection

        def is_same_waypoint_as x
          :string == x.shape_symbol && @s.object_id == x.__string.object_id
        end

        protected def __string
          @s
        end

        def description_under expag
          s = String_.ellipsify( @s ).inspect
          expag.calculate do
            val s
          end
        end

        def shape_symbol
          :string
        end

      end
    end
  end
end
