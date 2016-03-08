module Skylab::Human

  NLP::EN.const_get :Phrase_Structure_, false

  module NLP::EN::Phrase_Structure_

    class NLP::EN::POS::Noun < Models::Syntactic_Category

      GRAMMATICAL_CATEGORIES = [ :definity, :number, :person ]

      UNIQUE_EXPONENTS = {

        indefinite: :definity,
        definite: :definity,
        _do_not_use_article_: :definity,
        the_negative_determiner: :definity,
        the_counterpart_quantity_determiner: :definity,

        singular: :number,
        plural: :number,

        first: :person,
        second: :person,
        third: :person,
      }

      # ~ for the lexical categories in our lexicon (noun only for now):

      Attributes_actor_[ self ]

      class << self

        def new_via_lemma_and_iambic lemma_x, x_a

          st = polymorphic_stream_via_iambic x_a

          ok = false
          lemma = new lemma_x do
            ok = process_polymorphic_stream_fully st
          end
          ok && lemma

        end

        private :new
      end  # (..)

      attr_reader :is_mass_noun

     private

      def mass_noun=
        @is_mass_noun = true
        KEEP_PARSING_
      end

    public

      # ~ end

      class << self

        def [] lemma_s=nil

          if lemma_s

            if PRONOUN_GATEWAY___ == lemma_s
              __pronoun_macro
            else
              self::Omni_Phrase.new in_lexicon_touch_lemma_via_string lemma_s
            end
          else
            self::Omni_Phrase.new nil
          end
        end

        def __pronoun_macro  # see [#037] #the-pronoun-gateway-hack

          np = self::Omni_Phrase.new nil
          np << :neuter << :singular << :third
          np << :objective   # we don't technicallly know this but meh
        end

        def phrase_via_parse st
          Noun_::Hacktors_::Parse_noun_phrase.via_parse st
        end

        def phrase_via_string s
          Noun_::Hacktors_::Parse_noun_phrase.via_string s
        end

        def lexeme_class
          self
        end
      end  # >>

      PRONOUN_GATEWAY___ = 'it'

      @lexicon_ = Lazy_lexicon_[ self, :LEXICON_PROTOTYPE___ ]

      class Omni_Phrase < Omni_Phrase

        ORDER_WHEN_NORMAL___ = %i(

          quantity_hack_
          article
          adjective_phrase
          lexeme
          prepositional_phrases )

        ORDER_WHEN_PRONOUN_IS_ACTIVE___ = %i(

          quantity_hack_
          adjective_phrase
          _pronoun
          prepositional_phrases

        )  # "neither of them"

        UNIQUE_EXPONENTS = UNIQUE_EXPONENTS

        def initialize any_lexeme

          @_article = nil
          @_number = nil
          @_person = nil
          @_pronoun = nil
          @pronoun_is_active = false
          super
        end

        # ~ legacy oneliners for #open [#035]

        def indefinite_singular

          self << :indefinite << :singular
          to_string
        end

        def lemma

          @lexeme.to_lemma_string
        end

        def plural

          self << :plural
          to_string
        end

        def singular

          self << :singular
          @lexeme.to_lemma_string
        end

        # ~ end

        def inflect_words_into_against_noun_phrase y, _np

          # ..
          express_words_into y
        end

        def inflect_child_production_ y, phrase
          phrase.inflect_words_into_against_noun_phrase y, self
        end

        # ~ experimentally, both exponents and constituent phrase structures:

        def << exponent_symbol

          cat_sym = self.class::UNIQUE_EXPONENTS[ exponent_symbol ]
          if cat_sym
            send :"__change__#{ cat_sym }__", exponent_symbol
          else
            __change_exponent_of_pronoun exponent_symbol
          end
          self
        end

        attr_reader :pronoun_is_active

        def __change_exponent_of_pronoun sym

          if ! @_pronoun
            @_pronoun = EN_::POS::Pronoun.new_production
            @pronoun_is_active = true
          end

          @_pronoun << sym

          NIL_
        end

        def clear_grammatical_category cat_sym

          ivar = Noun_.__irreg_idx.my_category_ivar_h[ cat_sym ]

          if ivar
            instance_variable_set ivar, nil
          else

            pn = @_pronoun
            pn.clear_grammatical_category cat_sym
            if pn.is_empty
              @pronoun_is_active = false
            end
          end
          NIL_
        end

        attr_reader :adjective_phrase

        def remove_adjective_phrases
          remove_instance_variable :@adjective_phrase
        end

        def remove_first_adjective

          @adjective_phrase.remove_first_item
        end

        def prepend_adjective_via_lemma s

          _ = EN_::Phrase_Structure::Noun_inflectee_via_string[ s ]
          prepend_adjective_phrase _
        end

        def prepend_adjective_phrase x
          touch_and_prepend_noun_inflectee_into_ :@adjective_phrase, x
        end

        def article
          @_article || Article__.default_instance
        end

        def use_indefinite_article_if_appropriate

          if @lexeme.is_mass_noun
            NIL_
          else
            _change_definity :indefinite
            ACHIEVED_
          end
        end

        def __change__definity__ def_or_indef
          _change_definity def_or_indef
        end

        def _change_definity def_or_indef

          @_article = Article__.send def_or_indef
          @pronoun_is_active = false  # why ?
          NIL_
        end

        def lemma_string= s
          @lexeme = Noun_.in_lexicon_touch_lemma_via_string s
          @pronoun_is_active = false
          s
        end

        def number
          @_number || Number___.default_instance
        end

        def __change__number__ plur_or_sing
          @_number = plur_or_sing
          NIL_
        end

        def person
          @_person
        end

        attr_reader :_pronoun

        def __change__person__ first_second_third
          @_person = first_second_third
          NIL_
        end

        attr_reader :prepositional_phrases

        def append_prepositional_phrase x
          touch_and_append_noun_inflectee_into_ :@prepositional_phrases, x
        end

        attr_accessor :quantity_hack_

        def current_phrase_order_
          if @pronoun_is_active
            ORDER_WHEN_PRONOUN_IS_ACTIVE___
          else
            ORDER_WHEN_NORMAL___
          end
        end
      end

      define_singleton_method :__irreg_idx, IRREGULAR_INDEX_METHOD_

      module Article__

        # since we never use them outside of noun phrases, articles get
        # their own ad-hoc treatment here, rather than being implemented
        # as syntactic categories proper (for now).

        class << self

          attr_reader(
            :definite,
            :_do_not_use_article_,
            :indefinite,
            :the_counterpart_quantity_determiner,
            :the_negative_determiner,
            :default_instance )
        end

        @definite = module DEFINITE___
        class << self

          def inflect_words_into_against_noun_phrase y, phrase
            y << 'the'
          end

          def intern
            :definite
          end
        end # >>
          self
        end

        @_do_not_use_article_ = module DO_NOT_USE_ARTICLE___
        class << self

          def inflect_words_into_against_noun_phrase y, phrase
            y
          end

          def intern
            :_do_not_use_article_
          end
        end # >>
          self
        end

        @indefinite = module INDEFINITE___

          class << self

            def inflect_words_into_against_noun_phrase y, phrase

              if :singular == phrase.number.intern
                y << __money( phrase.lexeme.to_lemma_string )
              end
              y
            end

            define_method :__money, -> do

              initial_vowel_rx = /\A[aeiou]/i  # :+#cp
              all_caps_rx = /\A[A-Z]+\z/

              -> lemma_s do

                x = if initial_vowel_rx =~ lemma_s
                  'an'
                else
                  'a'
                end
                if all_caps_rx =~ lemma_s
                  x.upcase
                else
                  x
                end
              end
            end.call

            def intern
              :indefinite
            end
          end  # >>
          self
        end

        @the_counterpart_quantity_determiner =
        module THE_COUTERPART_QUANTITY_DETERMINER___
        class << self

          def inflect_words_into_against_noun_phrase y, np
            y << 'any'
          end

          def intern
            :the_counterpart_quantity_determiner
          end
        end  # >>
          self
        end

        @the_negative_determiner = module THE_NEGATIVE_DETERMINER___
        class << self

          def inflect_words_into_against_noun_phrase y, np
            sing_or_plur = np.person
            if sing_or_plur
              # 'not' ?
              y << 'no'
            else
              y << 'no'
            end
          end

          def intern
            :the_negative_determiner
          end
        end # >>
          self
        end

        @default_instance = @indefinite
      end

      module Number___

        class << self
          attr_reader :default_instance
        end  # >>

        @default_instance = :singular
      end

      def inflect_words_into_against_noun_phrase y, noun_phrase

        s = @to_lemma_string

        if :singular == noun_phrase.number.intern
          y << s
        else
          y << Add_S_ending_[ s ]
        end
      end

      Noun_ = self
    end
  end
end
