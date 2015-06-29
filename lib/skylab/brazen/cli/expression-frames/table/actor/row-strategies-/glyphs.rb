module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Row_Strategies_::Glyphs

      ARGUMENTS = [
        :argument_arity, :one, :property, :left,
        :argument_arity, :one, :property, :right,
        :argument_arity, :one, :property, :sep,
      ]

      ROLES = [
        :argument_matrix_expresser,
      ]

      SUBSCRIPTIONS = [
        :argument_bid_for,
        :known_width
      ]

      Table_Impl_::Strategy_::Has_arguments[ self ]

      def initialize x

        @_left_flank = LEFT_GLYPH_
        @parent = x
        @_right_flank = RIGHT_GLYPH_
        @_separator_glyph = SEP_GLYPH_
      end

      def dup x
        otr = super()
        otr.__init_dup x
        otr
      end

      def initialize_copy _
        @_down_o = false  # sanity - don't carry across dup boundary
      end

      def __init_dup x
        @parent = x
        NIL_
      end

      def receive__left__argument x

        @_left_flank = x
        KEEP_PARSING_
      end

      def receive__right__argument x

        @_right_flank = x
        KEEP_PARSING_
      end

      def receive__sep__argument x

        @_separator_glyph = x
        KEEP_PARSING_
      end

      def receive_downstream_context o

        @_down_o = o
        KEEP_PARSING_
      end

      def known_width

        total = @_left_flank.length + @_right_flank.length
        d = @parent.known_columns_count
        if 1 < d
          total += @_separator_glyph.length * ( d - 1 )
        end
        total
      end

      def express_argument_matrix_against_celifiers am, c

        lf = @_left_flank
        rf = @_right_flank
        sep = @_separator_glyph

        am.accept_by do | x_a |

          _s_a_ = x_a.each_with_index.map do | x, d |
            c[ d ][ x ]
          end

          @_down_o << "#{ lf }#{ _s_a_ * sep }#{ rf }"
        end

        @_down_o.appropriate_result
      end
    end
  end
end
