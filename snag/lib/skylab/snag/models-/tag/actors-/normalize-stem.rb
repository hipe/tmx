module Skylab::Snag

  class Models_::Tag

    Actors_ = ::Module.new

    class Actors_::Normalize_stem < Callback_::Actor::Monadic  # 1x <

      def initialize x, & p
        @on_event_selectively = p
        @x = x
      end

      def execute

        x = @x
        @symbol = if x.respond_to? :ascii_only?
          x.intern
        else
          x  # assumed
        end

        @as_string = "##{ @symbol.id2name }"  # :+[#007] add hashtag prefix

        st = Home_::Models::Hashtag::Stream[ @as_string ]

        sym_o = st.gets

        if sym_o
          if :hashtag == sym_o.category_symbol
            @symbol = sym_o
            _rest = st.gets
            if _rest
              _when_invalid
            else
              Callback_::Known_Known[ @symbol.get_stem_string.intern ]
            end
          else
            _when_invalid
          end
        else
          _when_invalid
        end
      end

      def _when_invalid
        @on_event_selectively.call :error, :invalid_tag_stem do
          __build_invalid_event
        end
      end

      def __build_invalid_event

        Callback_::Event.inline_not_OK_with :invalid_tag_stem,

            :tag_s, @as_string do | y, o |

          y << "tag must be alphanumeric separated with dashes - #{
           }invalid tag name: #{ ick o.tag_s }"
        end
      end
    end
  end
end
# :+#tombstone changed event
