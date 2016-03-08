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
          },
          'set' => {
            [ :preterite ] => 'set',
          },
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

        ORDER_WHEN_NORMAL___ = [

          # "is definitely not yet supported easily"

          :lexeme,
          # early adverb?
          :negation,
          :middle_adverb_phrase,
          :object_noun_phrase,
          :late_adverb_phrase,
        ]  # or whatever

        ORDER_WHEN_AUXILIARY___ = [

          # "can not easily make things quickly"

          :auxiliary,
          :negation,
          :middle_adverb_phrase,
          :lexeme_as_auxiliary_counterpart,
          :object_noun_phrase,
          :late_adverb_phrase
        ]

        UNIQUE_EXPONENTS = UNIQUE_EXPONENTS

        def initialize noun_phrase, lexeme

          super lexeme
          @be_gerund = false  # hact'd for now
          @is_negative = false
          @_spc = Sentence_Phrase_Constituency_.new noun_phrase, self
          @_tense = nil
        end

        def << exponent_symbol

          _cat_sym = self.class::UNIQUE_EXPONENTS.fetch exponent_symbol

          send :"__change__#{ _cat_sym }__", exponent_symbol
          self
        end

        # ~ experimentally, exponents, constituent phrase structures and
        #     "phrase properties" are all here:

        # ~ a

        def auxiliary  # assume etc

          send :"__build__#{ _auxiliary_reason }__"
        end

        # ~ g

        attr_writer :be_gerund  # hact for now

        # ~ l

        attr_reader :late_adverb_phrase

        def initialize_late_adverb_via_lemma s

          @late_adverb_phrase = if s
            EN_::Phrase_Structure::Sentence_inflectee_via_string[ s ]
          else
            s
          end
          NIL_
        end

        # ~ m

        attr_reader :middle_adverb_phrase

        def initialize_middle_adverb_via_lemma s
          @middle_adverb_phrase = if s
            EN_::Phrase_Structure::Sentence_inflectee_via_string[ s ]
          else
            s
          end
          NIL_
        end

        # ~ n

        def negation
          if @is_negative
            THE_NEGATION_PHRASE___
          end
        end

        attr_reader :is_negative

        def become_negative
          @is_negative = true
          NIL_
        end

        # ~ o

        attr_accessor :object_noun_phrase

        # ~ t

        def tense
          @_tense || :present
        end

        def __change__tense__ to
          @_tense = to
          NIL_
        end

        # ~ support & hook-outs

        def inflect_child_production_ y, phrase

          phrase.inflect_words_into_against_sentence_phrase y, @_spc
        end

        def current_phrase_order_

          if _auxiliary_reason
            ORDER_WHEN_AUXILIARY___
          else
            ORDER_WHEN_NORMAL___
          end
        end

        def _auxiliary_reason

          if @be_gerund

            NIL_

          elsif :progressive == @_tense  # "runs" => "is running"

            # (progressive can be negated, so check progressive before negation)

            :auxiliary_because_progressive

          elsif @is_negative

            s = @lexeme.lemma_x

            if ! ( BE__ == s )

              # "is not", !"does not be"
              # !"does not", "does not do"  # we might change this

              :auxiliary_because_regular_negation
            end
          end
        end

        def __build__auxiliary_because_progressive__

          # "i am not having a good time" (conjugate "be" for the noun)

          Verb_[ @_spc.noun_phrase, BE__ ]
        end

        def __build__auxiliary_because_regular_negation__

          Verb_[ @_spc.noun_phrase, DO__ ]
        end

        BE__ = 'be' ; DO__ = 'do'

        def lexeme_as_auxiliary_counterpart

          if :progressive == @_tense
            @lexeme
          else
            For_Auxiliary_Counterpart_Use_Uninflected_Lemma___[ @lexeme ]
          end
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

      def __inflect_for__progressive__tense y, _sp
        inflect_for_progressive_tense_ y
      end

      def inflect_for_progressive_tense_ y

        s = @to_lemma_string

        case s
        when ENDS_IN_E_RX__

          y << "#{ $~.pre_match }ing"  # "mate" -> "mating"

        when DOUBLE_T_RX___

          y << "#{ s }ting"  # "set" -> "setting"

        else
          y << "#{ s }ing"
        end
      end

      ENDS_IN_E_RX__ = /e\z/i

      DOUBLE_T_RX___ = /[aeiou]t\z/

      def is_regular
        true
      end

      module THE_NEGATION_PHRASE___
        class << self
          def inflect_words_into_against_sentence_phrase y, sp

            # if is casual "'nt" eek
            y << 'not'
          end
        end  # >>
      end

      class For_Auxiliary_Counterpart_Use_Uninflected_Lemma___
        class << self
          alias_method :[], :new
        end
        def initialize lx
          @_lexeme = lx
        end
        def inflect_words_into_against_sentence_phrase y, sp
          y << @_lexeme.lemma_x
        end
      end

      Verb_ = self
    end
  end
end

# now we write regular rules procedurally, but :+#tombstone a DSL
