module Skylab::Basic

  module List

    module ByteUpstreamReference ; class << self
      def via_line_array s_a
        ByteStreamReference__.define do |o|
          o.will_be_readable
          o.line_array = s_a
        end
      end
    end ; end

    module ByteDownstreamReference ; class << self
      def via_line_array s_a
        ByteStreamReference__.define do |o|
          o.will_be_writable
          o.line_array = s_a
        end
      end
    end ; end

    class ByteStreamReference__ < Common_::SimpleModel

      # #[#ba-062.1] & #[#ba-062.2] comport to this semi-unified interface
      # for reading and writing bytes to and from a byte store. this
      # adaptation is for arrays whereby the lines of data are stored as
      # the elements of the array. see manifesto.

      # shh don't tell we only ever use this to mock an IO stream opened
      # for reading or writing or read-writing as appropriate.

      def initialize
        super  # hi.
      end

      def will_be_writable
        @IS_WRITABLE = true  # only for easy inpsection
        extend MethodsForDownstream___ ; nil
      end

      def will_be_readable
        @IS_READABLE =  # only for easy inspection
        extend MethodsForUpstream___ ; nil
      end

      attr_writer(
        :line_array,
      )
    end  # (will re-open)

    module MethodsForDownstream___

      def description_under expag
        "«output stream»"  # :#guillemets
      end

      def to_minimal_yielder_for_receiving_lines  # #[#046]
        @line_array.clear
        @line_array
      end
    end

    module MethodsForUpstream___

      def description_under expag
        "«input stream»"  # #guillemets
      end

      def to_mutable_whole_string
        @line_array * EMPTY_S_
      end

      alias_method :to_read_only_whole_string, :to_mutable_whole_string

      def to_minimal_line_stream
        Stream_[ @line_array ]
      end
    end

    class ByteStreamReference__  # (re-open)

      def to_TWO_WAY_byte_stream_reference  # [tm] experiment. see NOTE next
        __redefine do |o|
          o.will_be_readable
          o.will_be_writable
        end
      end

      def __redefine  # NOTE - this does not dup the array. so if you have
        # a read-only reference and you spawn from it a read-write reference,
        # it will modify the original array. the workaround is trivial.
        otr = dup
        yield otr
        otr.freeze
      end

      def is_same_waypoint_as otr
        if :line_list == otr.shape_symbol
          @line_array.object_id == otr.line_array.object_id
        end
      end

      attr_reader :line_array
      protected :line_array  # for now

      def shape_symbol
        :line_list
      end

      def modality_const
        :ByteStream
      end
    end

    # ==


    # ==
    # ==
  end
end
