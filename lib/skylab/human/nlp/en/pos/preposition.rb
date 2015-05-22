module Skylab::Human

  NLP::EN.const_get :Phrase_Structure_, false

  module NLP::EN::Phrase_Structure_

    class NLP::EN::POS::Preposition  # < Models::Syntactic_Category

      class << self

        def phrase_via np, lem

          new.__phrase_via_etc np, lem
        end

        def phrase_via_parse st

          if PREP_LEXICON__[ st.current_token.last ]

            new.__phrase_via_parse st
          end
        end

        private :new
      end  # >>

      PREP_LEXICON__ = ::Hash[
        [
          "after",  # tests here
          "in",  # [sy]
          "of",
          "with",  # [sy]

        ].map { | s | [ s, true ] } ]

      def initialize
      end

      def noun_phrase  # maybe..
        @_np
      end

      def __phrase_via_parse st

        @_lemma = st.current_token.last
        st.advance_one
        _np = EN_::POS::Noun.phrase_via_parse st
        @_np = _np
        self
      end

      def __phrase_via_etc np, lem

        PREP_LEXICON__.fetch lem  # sanutus
        @_lemma = lem
        @_np = np
        self
      end

      def to_stream_of_pronouns
        if @_np.pronoun_is_active
          Callback_::Stream.via_item @_np
        end
      end

      def express_words_into_under y, expag
        y << @_lemma
        @_np.express_words_into_under y, expag
      end

      def inflect_words_into_against_noun_phrase y, np
        y << @_lemma
        @_np.inflect_words_into_against_noun_phrase y, np
      end

      def inflect_words_into_against_sentence_phrase y, np
        y << @_lemma
        @_np.inflect_words_into_against_sentence_phrase y, np
      end
    end
  end
end
