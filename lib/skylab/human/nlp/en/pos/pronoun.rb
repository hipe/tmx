module Skylab::Human

  NLP::EN.const_get :Phrase_Structure_, false

  module NLP::EN::Phrase_Structure_

    module EN_::POS::Pronoun

      GRAMMATICAL_CATEGORIES = [ :case, :gender, :number, :person ]

      UNIQUE_EXPONENTS = {

        objective: :case,
        subjective: :case,

        feminine: :gender,
        masculine: :gender,
        neuter: :gender
      }

      PARENT = -> { NLP::EN::POS::Noun }

      LEXICON_OF_IRREGULARS = -> do

        # the pronoun is :#special: our treatment of it is as lexicon
        # with only one lexeme with many irregular forms and no lemma.

        { nil => {

          # case, gender, number, person

          [       :second ] => 'you',

          [ :objective,   :plural, :first ] => 'us',

          [ :objective,   :plural, :third ] => 'them',

          [ :objective,   :singular, :first] => 'me',

          [ :objective, :feminine, :singular, :third ] => 'her',

          [ :objective, :masculine, :singular, :third ] => 'him',

          [ :subjective,   :plural, :first ] => 'we',

          [ :subjective,   :plural, :third ] => 'they',

          [ :subjective,   :singular, :first ] => 'I',

          [ :subjective, :feminine, :singular, :third ] => 'she',

          [ :subjective, :masculine, :singular, :third ] => 'he',

          [   :singular, :neuter, :third ] => 'it'  # sounds more natural after above :/
        } }
      end

      define_singleton_method :irregular_index, IRREGULAR_INDEX_METHOD_

      class << self
        def new_production
          Production___.new
        end
      end

      class Production___

        def initialize

          @case = nil
          @gender = nil
        end

        attr_reader :case, :gender

        def is_empty

          ! ( @case || @gender )
        end

        def << exp_sym  # :+#ac

          _ivar = _exponent_index.my_exponent_ivar_h.fetch exp_sym
          instance_variable_set _ivar, exp_sym
          self
        end

        def clear_grammatical_category sym  # :+#ac

          _ivar = _exponent_index.my_category_ivar_h.fetch sym
          instance_variable_set _ivar, NIL_
          NIL_
        end

        def inflect_words_into_against_sentence_phrase y, sp
          inflect_words_into_against_noun_phrase y, sp
        end

        def inflect_words_into_against_noun_phrase y, np

          _and_a = __to_grammatical_category_state_around_ np

          _lx = __irregular_index_.irregular_collection.entry_for NIL_  # #special

          _lx.inflect_words_into_against_exponent_state y, _and_a
        end

        def __to_grammatical_category_state_around_ phrase  # :+#ac

          idx = _exponent_index
          and_a = []
          ivar_h = idx.my_category_ivar_h

          idx.grammatical_categories.each do | sym |

            ivar = ivar_h[ sym ]
            x = if ivar
              instance_variable_get ivar
            else
              phrase.send sym
            end
            x or next
            and_a.push [ sym, x ]
          end

          if and_a.length.nonzero?
            and_a
          end
        end

        def _exponent_index
          Pron_.irregular_index
        end

        def __irregular_index_
          Pron_.irregular_index
        end
      end

      Pron_ = self
    end
  end
end
