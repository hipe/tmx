module Skylab::Human

  NLP::EN.const_get :Phrase_Structure_, false

  module NLP::EN::Phrase_Structure_

    class NLP::EN::POS::Sentence < Models::Syntactic_Category

      class << self

        def [] np, vp
          self::Omni_Phrase.new np, vp
        end
      end  # >>

      class Omni_Phrase < Omni_Phrase

        ORDER_WHEN_NORMAL___ = %i(

          early_modifier_clause
          noun_phrase
          verb_phrase
          conjunctive_tail_
        )

        ORDER_WHEN_ADVERBIALLY_INVERTED___ = %i(

          early_modifier_clause
          inversional_adverb
          verb_phrase
          noun_phrase
          conjunctive_tail_
        )

        def initialize np, vp

          @_is_adverbially_inverted = false
          @noun_phrase = np
          @verb_phrase = vp
          super nil
        end

        def inflect_child_production_ y, phrase

          phrase.inflect_words_into_against_sentence_phrase y, self
        end

        # ~ in order

        attr_reader :early_modifier_clause

        def prepend_early_modifier_clause ph

          touch_mutable_list_ :@early_modifier_clause,
            Early_Modifier_Clause___, ph do | list |

            list.prepend_sentence_inflectee ph
          end
          NIL_
        end

        attr_reader :inversional_adverb

        def initialize_adverbial_inversion lemma_s

          # we're calling "adverbial inversion" whatever this is:
          #
          #   "quickly beats my heart"
          #   "here lies arthur"
          #   "there is problem"
          #   "where is waldo"
          #   "how are you doing"
          #
          # if we use it for any arbitrary expression, it's arcane-sounding.
          # but like the irregular verbs, it's absolutely essential for this
          # one kind of verb-concept of expressing or questioning existence:
          #
          #   "no money is there in my bank account"  (awkward)
          #   "there is no money in my bank account"  (natural)
          #
          # note that the adverbs that are naturally used in this form
          # are of a small set:
          #
          #   here there who what when where how (..?)
          #
          # so this order-form is used to form questions and to express
          # existence.
          #
          #   "there is a lot you don't know about me" (natural)
          #   "a lot you don't know about me is there" (awkward)

          @_is_adverbially_inverted = true
          @inversional_adverb =
            EN_::Phrase_Structure::Sentence_inflectee_via_string[ lemma_s ]

          NIL_
        end

        attr_reader :noun_phrase, :verb_phrase

        def replace_noun_phrase x_
          x = remove_instance_variable :@noun_phrase
          @noun_phrase = x_
          x
        end

        attr_accessor :conjunctive_tail_  # hac't for now

        def << exponent_symbol
          self._FUN
        end

        # ~ support & hook-outs

        def current_phrase_order_

          if @_is_adverbially_inverted
            ORDER_WHEN_ADVERBIALLY_INVERTED___
          else
            ORDER_WHEN_NORMAL___
          end
        end

        class Early_Modifier_Clause___ <
            EN_::Phrase_Structure::Mutable_phrase_list_as_sentence_inflectee

          def inflect_words_into_against_sentence_phrase y, sp
            super
            y << ','
          end
        end
      end
    end
  end
end
