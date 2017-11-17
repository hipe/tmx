module Skylab::Zerk

  module ArgumentScanner

    class FeatureBranch_via_FREEFORM  # #cover-me 1x [ts]  :[#051.F].

      # #[#051] - experiment. (used by the client to let method-based
      # and filesystem-based operations live in the same compound operator
      # branch. "routings" for the former are written into here "by hand".)

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      # -

        def initialize
          @_box = Common_::Box.new
          yield self
        end

        # -- define

        def add sym, item
          @_box.add sym, item
        end

        # -- read

        def emit_idea_by
          NOTHING_
        end

        def lookup_softly k  # #[#ze-051.1] "trueish item value"
          @_box[ k ]
        end

        def dereference k  # #[#ze-051.1] "trueish item value"
          @_box.fetch k
        end

        def to_pair_stream
          @_box.to_pair_stream
        end

        def to_loadable_reference_stream
          @_box.to_key_stream
        end
      # -
      # ==
    end
  end
end
