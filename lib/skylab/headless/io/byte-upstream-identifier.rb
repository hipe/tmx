module Skylab::Headless

  module IO

    class Byte_Upstream_Identifier < Byte_Identifer_

      # a :+[#br-019] unified interface for accessing the bytes in a stream.
      #
      # unlike the other (current) implementations, this one is itself
      # stateful: there is only ever one input stream to read from.

      # ~ reflection

      def fallback_description_
        "«input stream»"  # :+#guillemets
      end

      def modality_const
        :Byte_Stream
      end

      # ~ data delivery

      def whole_string
        @io.read  # or whatever
      end

      def to_simple_line_stream
        @io
      end
    end
  end
end

# ( :+#tombstone: `default_entity_noun_stem`, `type` )
