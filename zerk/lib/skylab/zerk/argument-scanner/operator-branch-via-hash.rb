module Skylab::Zerk

  module ArgumentScanner

    class OperatorBranch_via_Hash

      # frontier adaptation of #[#051] (hashes)
      # (#a.s-coverpoint-1)

      class << self
        alias_method :call, :new
        alias_method :[], :call
        undef_method :new
      end  # >>

      # -
        def initialize h
          @hash = h
        end

        def emit_idea_by
          NOTHING_
        end

        def lookup_softly k
          @hash[ k ]
        end

        def dereference k
          @hash.fetch k
        end

        def to_pair_stream
          to_normal_symbol_stream.map_by( & method( :pair_via_normal_symbol ) )
        end

        def pair_via_normal_symbol k
          Common_::Pair.via_value_and_name @hash.fetch(k), k
        end

        def to_normal_symbol_stream
          Stream_[ @hash.keys ]
        end
      # -
    end
  end
end
#history: broke out of "magnetics" for public exposure.
