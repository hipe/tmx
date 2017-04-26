module Skylab::Basic

  module String

    class ByteUpstreamReference < ::Class.new  # #[#ba-062.2]

      # comport to a universal interface for accessing the bytes in a string.

      # -

        # -- data delivery

        def whole_string
          @_string_
        end

        def TO_REWOUND_SHAREABLE_LINE_UPSTREAM_EXPERIMENT
          _same
        end

        def to_minimal_line_stream
          _same
        end

        def _same
          Here_::LineStream_via_String[ @_string_ ]
        end

        def BYTE_STREAM_REFERENCE_SHAPE_IS_PRIMITIVE  # [tm] experiment
          TRUE
        end

      # -

      # ==

      CommonBase__ = superclass

      class ByteDownstreamReference < CommonBase__

        #  conform to #[#ba-062.2] a semi-unified interface for writing bytes to a string

        def to_minimal_yielder_for_receiving_lines  # :[#046]
          @_string_.clear  # this is what you want..
        end
      end

      # ==

      class CommonBase__

        def initialize s
          @_string_ = s
        end

        def is_same_waypoint_as otr
          if :string == otr.shape_symbol
            @_string_.object_id == otr._string_.object_id
          end
        end

        def description_under expag
          s = Here_.ellipsify( @_string_ ).inspect
          expag.calculate do
            val s
          end
        end

        attr_reader(
          :_string_,
        )
        protected :_string_


        def shape_symbol
          :string
        end

        def modality_const
          :ByteStream
        end
      end

      # ==
      # ==
    end
  end
end
