module Skylab::Snag

  class Models::Tag

    class Stem_Normalization_

      # :+[#ba-027] is a universally conventional normalizer (subset)
      # [#017] result is callback's result
      # [#043] employs case sensitivity

      class << self

        def normalize_argument_value x, & oes_p
          new( x, & oes_p ).__execute
        end

        private :new
      end  # >>

      def initialize x, & oes_p
        @x = x
        @on_event_selectively = oes_p
      end

      def __execute

        s = @x.to_s  # sometimes symbol

        if HASH_CHARACTER_BYTE___ != s.getbyte( 0 )

          # add this IFF necessary. this *is* a normalization, so we
          # accept the input in either way

          s = "#{ HASH_CHARACTER___ }#{ s }"

          @x = s  # error messages are easier to read if we include
            # this change in them (covered)
        end

        st = Models::Hashtag.scanner s

        sym_o = st.gets

        if sym_o
          if :hashtag == sym_o.symbol_i
            @symbol = sym_o
            _rest = st.gets
            if _rest
              _when_invalid
            else
              Snag_.lib_.basic.trio @symbol.get_stem_s.intern, true, nil
            end
          else
            _when_invalid
          end
        else
          _when_invalid
        end
      end

      def _when_invalid
        if @on_event_selectively
          @on_event_selectively.call :error, :invalid_tag_stem do
            Invalid__.new @x
          end
        else
          _ = Invalid__.new @x
          self._UNCOVERED_CODE_IS_BROKEN_CODE
          raise Invalid__.new( @x ).to_exception
        end
      end

      HASH_CHARACTER___ = '#'
      HASH_CHARACTER_BYTE___ = HASH_CHARACTER___.getbyte( 0 )

      Invalid__ = Event_[].new :tag_s do
        message_proc do |y, o|
          y << "tag must be alphanumeric separated with dashes - #{
           }invalid tag name: #{ ick o.tag_s }"
        end
      end
    end
  end
end
# :+#tombstone changed event
