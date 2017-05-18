module Skylab::Zerk

  module ArgumentScanner

    class OperatorBranch_via_Hash  # :[#051.A].

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

        def lookup_softly k  # #[#ze-051.1] "trueish item value"
          @hash[ k ]
        end

        def dereference k  # #[#ze-051.1] "trueish item value"
          @hash.fetch k
        end

        def to_pair_stream
          to_loadable_reference_stream.map_by( & method( :pair_via_normal_symbol ) )
        end

        def pair_via_normal_symbol k
          Common_::QualifiedKnownKnown.via_value_and_symbol @hash.fetch(k), k
        end

        def to_loadable_reference_stream
          Stream_[ @hash.keys ]
        end
      # -
    end
  end
end
#history: broke out of "magnetics" for public exposure.
