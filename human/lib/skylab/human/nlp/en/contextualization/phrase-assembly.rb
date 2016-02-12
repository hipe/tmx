module Skylab::Human

  class NLP::EN::Contextualization

    class Phrase_Assembly  # (not used elsewhere yet but duped :[#046].)

      def initialize
        @_tokens = []
      end

      def add_any_string s
        if s
          add_string s
        end
        NIL_
      end

      def add_string s
        @_tokens.push Plain_String___.new s
        NIL_
      end

      def add_lazy_space
        @_tokens.push Lazy_Space___[] ; nil
      end

      def add_comma
        @_tokens.push Comma___[] ; nil
      end

      def build_string_

        st = Callback_::Stream.via_nonsparse_array @_tokens
        tok = st.gets
        if tok
          # ..
          s = "#{ tok.s }"
          begin
            tok = st.gets
            tok or break
            if tok.is_prefixed_by_space
              s.concat SPACE_
            end
            s.concat tok.s
            redo
          end while nil
          s
        end
      end

      class Plain_String___
        def initialize s
          @s = s
        end
        attr_reader :s
        def is_prefixed_by_space
          true
        end
      end

      Lazy_Space___ = Lazy_.call do
        class Lazy_Space____
          def s
            EMPTY_S_
          end
          def is_prefixed_by_space
            true
          end
          self
        end.new
      end

      Comma___ = Lazy_.call do
        COMMA___ = ','
        class Comma____
          def s
            COMMA___
          end
          def is_prefixed_by_space
            false
          end
          self
        end.new
      end
    end
  end
end
