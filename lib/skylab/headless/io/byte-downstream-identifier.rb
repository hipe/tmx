module Skylab::Headless

  module IO

    class Byte_Downstream_Identifier

      # :+( near [#br-019] )

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
         "«output stream»"  # :+#guillemets
        end
      end

      def shape_symbol
        :stream
      end

      # ~ data acceptance exposures

      def to_minimal_yielder
        @io
      end
    end
  end
end
