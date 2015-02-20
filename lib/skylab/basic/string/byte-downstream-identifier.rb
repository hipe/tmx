module Skylab::Basic

  module String

    class Byte_Downstream_Identifier

      #  near :+[#br-019]: unified interface for writing bytes to a string

      def initialize s
        @s = s
      end

      # ~ reflection

      def description_under expag
        s = String_.ellipsify( @s ).inspect
        expag.calculate do
          val s
        end
      end

      def shape_symbol
        :string
      end

      # ~ data acceptance exposures

      def to_minimal_yielder
        @s.clear  # this is what you want..
      end
    end
  end
end
