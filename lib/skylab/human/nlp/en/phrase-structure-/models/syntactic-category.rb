module Skylab::Human

  module NLP::EN::Phrase_Structure_

    class Models::Syntactic_Category

      # currently this models both the particular syntactic category
      # (in its capacity as a module) and the particular lexemes of
      # that category (modeled as instances of this class). so think
      # of the instances of subclasses of this class as "lexemes".

      class << self

        # ~ reflection

        def has_exponent sym
          self::UNIQUE_EXPONENTS.key? sym
        end

        # ~ production

        def in_lexicon_touch_lemma_via_string lemma_form_string

          @lexicon_.touch lemma_form_string do
            new lemma_form_string
          end
        end

        private :new
      end  # >>

      def initialize lemma_form_string

        if ! lemma_form_string.frozen?
          lemma_form_string.freeze
        end
        @to_lemma_string = lemma_form_string
      end

      def lemma_x
        to_lemma_string
      end

      attr_reader :to_lemma_string

      class Omni_Phrase

        def initialize any_lexeme

          @lexeme = any_lexeme
        end

        attr_reader :lexeme

        def to_string
          express_words_into( [] ) * SPACE_
        end

        def inflect_words_into_against_sentence_phrase y, _

          # by definition these productions are inflexively self-contained

          express_words_into y
        end

        def express_words_into y

          determine_constituent_phrase_order_.each do | sym |
            x = send sym
            x or next
            inflect_child_production_ y, x
          end
          y
        end

        def determine_constituent_phrase_order_
          self.class::ORDER
        end
      end
    end
  end
end
