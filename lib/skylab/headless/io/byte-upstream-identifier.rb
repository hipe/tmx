module Skylab::Headless

  module IO

    class Byte_Upstream_Identifier

      # a :+[#br-019] unified interface for accessing the bytes in a stream.
      #
      # unlike the other (current) implementations, this one is itself
      # stateful: there is only ever one input stream to read from.

      def initialize io
        @io = io
      end

      # ~ reflection

      def description_under expag
        if @io.respond_to? :path
          path = @io.path
          expag.calculate do
            pth path
          end
        else
         "«input stream»"  # :+#guillemets
        end
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
