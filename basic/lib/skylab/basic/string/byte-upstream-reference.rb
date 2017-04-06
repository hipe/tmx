module Skylab::Basic

  module String

    class ByteUpstreamReference < ::Class.new  # #[#ba-062.2]

      # comport to a universal interface for accessing the bytes in a string.

      # ~ data delivery

      def whole_string
        @s
      end

      def TO_REWOUND_SHAREABLE_LINE_UPSTREAM_EXPERIMENT
        _same
      end

      def to_simple_line_stream
        _same
      end

      def _same
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
          :ByteStream
        end
      end
    end
  end
end
