module Skylab::Basic

  module String

    class Byte_Upstream_Identifier < ::Class.new  # :+[#br-019.D]

      # comport to a universal interface for accessing the bytes in a string.

      # ~ data delivery

      def whole_string
        @s
      end

      def to_simple_line_stream
        to_rewindable_line_stream
      end

      def to_rewindable_line_stream
        Here_::LineStream_via_String[ @s ]
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
          s = Here_.ellipsify( @s ).inspect
          expag.calculate do
            val s
          end
        end

        def shape_symbol
          :string
        end

        def modality_const
          :Byte_Stream
        end
      end
    end
  end
end
