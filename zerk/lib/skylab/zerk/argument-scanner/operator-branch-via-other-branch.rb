module Skylab::Zerk

  module ArgumentScanner

    class OperatorBranch_via_OtherBranch

      # #[#051] - experimentally for applying a mutation "mapping" over
      # another branch (for now only for subtraction) (abstracted from other)
      # (#a.s-coverpoint-1)

      # -

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

        def initialize otr
          @_not = :__first_not
          @_other = otr
          yield self
          remove_instance_variable :@_not
        end

        # -- define time

        # ~ (tacit assertion that `not` is called at least once)

        def not * sym_a
          send @_not, sym_a
        end

        def __first_not sym_a

          @_blacklist_hash = {}
          @_not = :__subsequent_not
          send @_not, sym_a
        end

        def __subsequent_not sym_a

          h = @_blacklist_hash
          sym_a.each do |sym|
            h[ sym ] = true
          end ; nil
        end

        # -- read-time

        def lookup_softly k
          x = @_other.lookup_softly k
          if x
            # hi.
            if @_blacklist_hash[ k ]
              NOTHING_  # hi.
            else
              x
            end
          end
        end

        def dereference k

          # (as we always do, we're assuming this key came from us.)

          @_other.dereference k
        end

        def to_pair_stream

          p = @_other.method :pair_via_normal_symbol

          to_normal_symbol_stream.map_by do |k|
            p[ k ]
          end
        end

        def to_normal_symbol_stream

          h = @_blacklist_hash

          @_other.to_normal_symbol_stream.reduce_by do |k|
            ! h[k]
          end
        end

      # -
    end
  end
end
# #history: abstracted from what is currently "via other branches"
