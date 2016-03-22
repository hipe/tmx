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

        def replace_lexicon x_
          x = @lexicon_
          @lexicon_ = x_
          x
        end

        private :new
      end  # >>

      # ~ this is the beginning and the end of the base
      #   instance methods for your lexeme subclass:

      def initialize lemma_form_string, & edit_p

        @to_lemma_string = lemma_form_string

        if edit_p
          instance_exec( & edit_p )
        end

        # (:+#tombstone: freezing)
      end

      def lemma_x

        # this form is compatible with e.g irregular lexemes that don't
        # have a stringular lemma of their own, for e.g The Pronoun

        to_lemma_string
      end

      attr_reader :to_lemma_string

      # ~ that's the end of it

      class Omni_Phrase

        def initialize any_lexeme

          @lexeme = any_lexeme
        end

        attr_reader :lexeme

        def to_string
          express_into ""
        end

        def express_into y

          _use_y = Home_.lib_.basic::Yielder::Mapper.joiner( y, SPACE_ ).y
          express_words_into _use_y
          y
        end

        def inflect_words_into_against_sentence_phrase y, _

          # by definition these productions are inflexively self-contained

          express_words_into y
        end

        def express_words_into y

          current_phrase_order_.each do | sym |
            x = send sym
            x or next
            inflect_child_production_ y, x
          end
          y
        end

        def current_phrase_order_
          self.class::ORDER
        end

        # ~ mutation API

        def touch_and_prepend_noun_inflectee_into_ ivar, x

          _touch_mutable_noun_inflectee_list ivar, x do | list |
            list.prepend_noun_inflectee x
          end
          NIL_
        end

        def touch_and_append_noun_inflectee_into_ ivar, x

          _touch_mutable_noun_inflectee_list ivar, x do | list |
            list.append_noun_inflectee x
          end
          NIL_
        end

        def touch_and_prepend_sentence_inflectee_into_ ivar, x

          _touch_mutable_sentence_inflectee_list ivar, x do | list |
            list.prepend_sentence_inflectee x
          end
          NIL_
        end

        def touch_and_append_sentence_inflectee_into_ ivar, x

          _touch_mutable_sentence_inflectee_list ivar, x do | list |
            list.append_sentence_inflectee x
          end
          NIL_
        end

        def _touch_mutable_noun_inflectee_list ivar, x, & p

          touch_mutable_list_ ivar,
            EN_::Phrase_Structure::Mutable_phrase_list_as_noun_inflectee,
            x, & p
        end

        def _touch_mutable_sentence_inflectee_list ivar, x, & p

          touch_mutable_list_ ivar,
            EN_::Phrase_Structure::Mutable_phrase_list_as_sentence_inflectee,
            x, & p
        end

        def touch_mutable_list_ ivar, cls, x

          if instance_variable_defined? ivar
            mutable_list = instance_variable_get ivar
          end

          if mutable_list
            yield mutable_list
          else
            instance_variable_set ivar, cls[ x ]
          end
          NIL_
        end
      end
    end
  end
end
