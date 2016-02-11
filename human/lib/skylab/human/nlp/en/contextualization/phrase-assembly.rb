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

      def add_space
        @_tokens.push Spacer___[] ; nil
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
            s.concat "#{ SPACE_ }#{ tok.s }"
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
      end

      Spacer___ = Lazy_.call do
        class Spacer____
          def s
            NOTHING_
          end
          self
        end.new
      end
    end
  end
end
