module Skylab::Human

  NLP::EN.const_get :Phrase_Structure_, false

  module NLP::EN::Phrase_Structure_

    class NLP::EN::POS::Verb < Models::Syntactic_Category

      GRAMMATICAL_CATEGORIES = [ :tense, :number, :person ]

      UNIQUE_EXPONENTS = {
        present: :tense,
        preterite: :tense,
        progressive: :tense
      }

      PARENT = -> { EN_::POS::Noun }

      LEXICON_OF_IRREGULARS = -> do  # etc

        are = 'are' ; do_ = 'do'
        go = 'go' ; have = 'have'
        was = 'was' ; were = 'were'
        {
          'be' => {
            [ :singular, :first, :present ] => 'am',
            [ :singular, :second, :present ] => are,
            [ :singular, :third, :present ] => 'is',
            [ :plural, :present ] => are,
            [ :singular, :first, :preterite ] => was,
            [ :singular, :second, :preterite ] => were,
            [ :singular, :third, :preterite ] => was,
            [ :plural, :preterite ] => were
          },
          'do' => {
            [ :singular, :first, :present ] => do_,
            [ :singular, :second, :present ] => do_,
            [ :singular, :third, :present ] => 'does',
            [ :plural, :present ] => do_,
            [ :preterite ] => 'did'
          },
          'go' => {
            [ :singular, :first, :present ] => go,
            [ :singular, :second, :present ] => go,
            [ :singular, :third, :present ] => 'goes',
            [ :plural, :present ] => go,
            [ :preterite ] => 'went'
          },
          'have' => {
            [ :singular, :first, :present ] => have,
            [ :singular, :second, :present ] => have,
            [ :singular, :third, :present ] => 'has',
            [ :plural, :present ] => have,
            [ :preterite ] => 'had'
          }
        }
      end

      class << self

        def [] noun_phrase=nil, lemma_form_string

          lexeme = in_lexicon_touch_lemma_via_string lemma_form_string

          if noun_phrase

            self::Omni_Phrase.new noun_phrase, lexeme

          else

            EN_::Phrase_Structure_::Oneliner_Adapters::For_Verb.new lexeme
          end
        end
      end  # >>

      @lexicon_ = Compound_Lexicon_.new self

      class Omni_Phrase < Omni_Phrase

        ORDER = [ :auxiliary, :negation, :early_adverb, :lexeme ]  # etc

        UNIQUE_EXPONENTS = UNIQUE_EXPONENTS

        def initialize noun_phrase, lexeme

          super lexeme
          @_spc = Sentence_Phrase_Constituency_.new noun_phrase, self
          @_tense = nil
        end

        # "can not adequetly fail"

        def inflect_child_production_ y, phrase

          phrase.inflect_words_into_against_sentence_phrase y, @_spc
        end

        def auxiliary

          if :progressive == @_tense

            # "i am having a time" (conjugate "be" for the noun)

            Verb_[ @_spc.noun_phrase, BE___ ]
          end
        end
        BE___ = 'be'

        def negation
        end

        def early_adverb
        end

        def tense
          @_tense || :present
        end

        def << exponent_symbol

          _cat_sym = self.class::UNIQUE_EXPONENTS.fetch exponent_symbol

          send :"__change__#{ _cat_sym }__", exponent_symbol
          self
        end

        def __change__tense__ to
          @_tense = to
          NIL_
        end
      end

      def inflect_words_into_against_sentence_phrase y, sp

        send :"__inflect_for__#{ sp.tense }__tense", y, sp
      end

      def __inflect_for__preterite__tense y, _sp=nil

        s = @to_lemma_string
        md = ENDS_IN_E_RX__.match s
        if md
          s = md.pre_match
        end
        y << "#{ s }ed"
      end

      def __inflect_for__present__tense y, sp

        if :singular == sp.number.intern && :third == sp.person.intern

          y << Add_S_ending_[ @to_lemma_string ]
        else
          y << @to_lemma_string
        end
      end

      def __inflect_for__progressive__tense y, _sp=nil

        s = @to_lemma_string

        case s
        when ENDS_IN_E_RX__

          y << "#{ $~.pre_match }ing"  # "mate" -> "mating"

        when DOUBLE_T_RX___

          y << "#{ s }ting"  # "set" -> "setting"

        else
          y << "#{ s }ing"
        end
        y
      end

      ENDS_IN_E_RX__ = /e\z/i

      DOUBLE_T_RX___ = /[aeiou]t\z/

      Verb_ = self
    end
  end
end

# now we write regular rules procedurally, but :+#tombstone a DSL
