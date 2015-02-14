module Skylab::Headless

  module IO

    class Byte_Downstream_Identifier

      # :+( near [#br-019] )

      def initialize io
        @io = io
      end

      def members
        [ :Category_symboL ]
      end

      def Category_symboL
        :Input_streaM
      end
    end
  end
end
