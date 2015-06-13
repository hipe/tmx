module Skylab::Basic

  module String

    class Byte_Downstream_Identifier < String::Byte_Upstream_Identifier::Superclass

      #  near :+[#br-019]: unified interface for writing bytes to a string

      # ~ reflection

      def EN_preposition_lexeme
      end

      # ~ data acceptance exposures

      def to_minimal_yielder  # :[#046]
        @s.clear  # this is what you want..
      end
    end
  end
end
