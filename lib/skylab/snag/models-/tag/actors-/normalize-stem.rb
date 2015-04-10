module Skylab::Snag

  class Models_::Tag

    Actors_ = ::Module.new

    class Actors_::Normalize_stem

      Callback_::Actor.call self, :properties,
        :symbol

      def execute

        @as_string = "##{ @symbol.id2name }"  # :+[#007] add hashtag prefix

        st = Snag_::Models::Hashtag.simple_stream_via_string__ @as_string

        sym_o = st.gets

        if sym_o
          if :hashtag == sym_o.nonterminal_symbol
            @symbol = sym_o
            _rest = st.gets
            if _rest
              _when_invalid
            else
              Snag_.lib_.basic.trio @symbol.get_stem_string.intern, true, nil
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
