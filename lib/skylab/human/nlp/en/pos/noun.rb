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
        third: :person
      }

      class << self

        def [] lemma_s=nil

          if lemma_s
            _lexeme = in_lexicon_touch_lemma_via_string lemma_s
          end

          self::Omni_Phrase.new _lexeme
        end
      end  # >>

      @lexicon_ = Callback_::Box.new

      class Omni_Phrase < Omni_Phrase

        ORDER = %i( article adjective_phrase lexeme )

        UNIQUE_EXPONENTS = UNIQUE_EXPONENTS

        def initialize any_lexeme

          @_article = nil
          @_number = nil
          @_person = nil
          @_pronoun = nil
          @_use_pronoun = false
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

        def express_words_into y

          if @_use_pronoun
            @_pronoun.inflect_words_into_against_noun_phrase y, self
          else
            super
          end
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

        def __change_exponent_of_pronoun sym

          if ! @_pronoun
            @_pronoun = EN_::POS::Pronoun.new_production
            @_use_pronoun = true
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
              @_use_pronoun = false
            end
          end
          NIL_
        end

        attr_reader :adjective_phrase

        def remove_adjective_phrase
          remove_instance_variable :@adjective_phrase
        end

        def initialize_adjective_phrase x

          @adjective_phrase ||= begin
            yes = true
            x
          end
          yes or self._NO_CLOBBER
          NIL_
        end

        def article
          @_article || Article__.default_instance
        end

        def __change__definity__ def_or_indef

          @_article = Article__.send def_or_indef
          @_use_pronoun = false
          NIL_
        end

        def lemma_string= s
          @lexeme = Noun_.in_lexicon_touch_lemma_via_string s
          @_use_pronoun = false
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

        def __change__person__ first_second_third
          @_person = first_second_third
          NIL_
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

          def self.inflect_words_into_against_noun_phrase y, phrase
            y << 'the'
          end
          self
        end

        @_do_not_use_article_ = module DO_NOT_USE_ARTICLE___
          def self.inflect_words_into_against_noun_phrase y, phrase
            y
          end
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
          end  # >>
          self
        end

        @the_counterpart_quantity_determiner =
        module THE_COUTERPART_QUANTITY_DETERMINER___
          def self.inflect_words_into_against_noun_phrase y, np
            y << 'any'
          end
          self
        end

        @the_negative_determiner = module THE_NEGATIVE_DETERMINER___

          def self.inflect_words_into_against_noun_phrase y, np
            sing_or_plur = np.person
            if sing_or_plur
              # 'not' ?
              y << 'no'
            else
              y << 'no'
            end
          end
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
