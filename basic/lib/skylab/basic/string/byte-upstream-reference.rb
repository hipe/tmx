module Skylab::Basic

  module String

    module ByteUpstreamReference ; class << self

      def via_big_string s
        ByteStreamReference__.define do |o|
          o.will_be_readable
          o.big_string = s
        end
      end
    end ; end

    module ByteDownstreamReference ; class << self

      def via_big_string s
        ByteStreamReference__.define do |o|
          o.will_be_writable
          o.big_string = s
        end
      end
    end ; end

    class ByteStreamReference__ < Common_::SimpleModel

      # comport to #[#ba-062.1] & #[#ba-062.2] (see manifesto) whereby a
      # string is adapted to this minimal, universal interface for reading
      # and writing bytes (lines) to and from.

      def initialize
        super  # hi.
      end

      def will_be_writable
        @IS_WRITABLE = true  # for easy inspection only
        extend MethodsForDownstream___ ; nil
      end

      def will_be_readable
        @IS_READABLE = true  # for easy inspection only
        extend MethodsForUpstream___ ; nil
      end

      def big_string= s
        @_string_ = s
      end
    end  # (will re-open)

    module MethodsForUpstream___

      def to_mutable_whole_string
        @_string_.dup
      end

      def to_read_only_whole_string
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
    end

    module MethodsForDownstream___

        def to_minimal_yielder_for_receiving_lines  # :[#046]
          @_string_.clear  # this is what you want..
        end
    end

    class ByteStreamReference__  # (re-open)

      def description_under expag
        s = Here_.ellipsify( @_string_ ).inspect
        expag.calculate do
          mixed_primitive s  # used to be `val`
        end
      end

      def to_TWO_WAY_byte_stream_reference  # [tm] experiment. (see NOTE below)
        __redefine do |o|
          o.will_be_readable
          o.will_be_writable
        end
      end

      def __redefine

        # NOTE we don't do anything fancy like duping the string - even
        # though one reference might be read only and you spawn off of it
        # a read-write, the spawned reference will alter the original
        # string. you're on your own to deep dup (which would be trivial.)

        otr = dup
        yield otr
        otr.freeze
      end

        def is_same_waypoint_as otr
          if :string == otr.shape_symbol
            @_string_.object_id == otr._string_.object_id
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

      def BYTE_STREAM_REFERENCE_SHAPE_IS_PRIMITIVE  # [tm] experiment
        TRUE
      end
    end

    # ==

    # ==
    # ==
  end
end
