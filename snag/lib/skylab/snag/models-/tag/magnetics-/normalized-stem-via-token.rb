module Skylab::Snag

  class Models_::Tag

    class Magnetics_::NormalizedStem_via_Token < Common_::Monadic  # 1x <

      def initialize x, & p
        @listener = p
        @x = x
      end

      def execute

        x = @x
        @symbol = if x.respond_to? :ascii_only?
          x.intern
        else
          x  # assumed
        end

        @as_string = "##{ @symbol.id2name }"  # #[#007.A] add hashtag prefix

        st = Home_::Models::Hashtag::Stream[ @as_string ]

        sym_o = st.gets

        if sym_o
          if :hashtag == sym_o.category_symbol
            @symbol = sym_o
            _rest = st.gets
            if _rest
              _when_invalid
            else
              Common_::KnownKnown[ @symbol.get_stem_string.intern ]
            end
          else
            _when_invalid
          end
        else
          _when_invalid
        end
      end

      def _when_invalid
        @listener.call :error, :invalid_tag_stem do
          __build_invalid_event
        end
        UNABLE_
      end

      def __build_invalid_event

        Common_::Event.inline_not_OK_with :invalid_tag_stem,

            :tag_s, @as_string do | y, o |

          y << "tag must be alphanumeric separated with dashes - #{
           }invalid tag name: #{ ick o.tag_s }"
        end
      end
    end
  end
end
# :+#tombstone changed event
