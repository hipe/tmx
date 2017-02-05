module Skylab::Zerk

  module ArgumentScanner

    class OperatorBranch_via_OtherBranch  # :[#051.D].

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

        def lookup_softly k  # #[#ze-051.1] "trueish item value"
          trueish_x = @_other.lookup_softly k
          if trueish_x
            # hi.
            if @_blacklist_hash[ k ]
              NOTHING_  # hi.
            else
              trueish_x
            end
          end
        end

        def dereference k

          # (as we always do, we're assuming this key came from us.)

          @_other.dereference k
        end

        def to_pair_stream

          p = @_other.method :pair_via_normal_symbol

          to_load_ticket_stream.map_by do |k|
            p[ k ]
          end
        end

        def to_load_ticket_stream

          h = @_blacklist_hash

          @_other.to_load_ticket_stream.reduce_by do |k|
            ! h[k]
          end
        end

      # -
    end
  end
end
# #history: abstracted from what is currently "via other branches"
