module Skylab::Basic

  module String

    class ByteDownstreamReference < String::ByteUpstreamReference::Superclass

      #  conform to #[#ba-062.2] a semi-unified interface for writing bytes to a string

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
