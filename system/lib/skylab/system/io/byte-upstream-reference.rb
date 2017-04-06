module Skylab::System

  module IO

    class ByteUpstreamReference < Byte_Identifer_   # #[#ba-062.1]

      # comport to a semi-unified interface for accessing the bytes in a stream.
      #
      # unlike the other (current) implementations, this one is itself
      # stateful: there is only ever one input stream to read from.

      # ~ reflection

      def fallback_description_
        "«input stream»"  # :+#guillemets
      end

      # ~ data delivery

      def TO_REWOUND_SHAREABLE_LINE_UPSTREAM_EXPERIMENT
        @io.rewind
        @io
      end

      attr_reader :WAS_IO

      def whole_string
        @io.read  # or whatever
      end

      def to_simple_line_stream
        @io
      end

      def lockable_resource
        @io
      end
    end
  end
end

# ( :+#tombstone: `default_entity_noun_stem`, `type` )
