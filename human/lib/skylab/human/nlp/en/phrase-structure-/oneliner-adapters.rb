module Skylab::Human

  module NLP::EN

    module Phrase_Structure_

      module Oneliner_Adapters  # see [#037] #philosophy-of-why-oneliners

        Noun = ::Module

        Noun::Indefinite = -> lemma_s do

          np = POS__[]::Noun[ lemma_s ]
          np << :indefinite << :singular
          np.to_string
        end

        Noun::Plural = -> count_d=nil, lemma_s do

          if count_d && 1 == count_d
            lemma_s
          else

            # a default of `plural` is assumed because elsewise why
            # would you be calling this function in the first place

            np = POS__[]::Noun[ lemma_s ]
            np << :plural
            np.to_string
          end
        end

        Noun::Singular = -> plural_s do

          # a placeholder for something smarter

          plural_s.sub %r( [sS]\z )x, EMPTY_S_
        end

        module Verb

          class << self

            def __preterite lemma_s

              _common( lemma_s ).preterite
            end

            def __progressive lemma_s

              _common( lemma_s ).progressive
            end

            def __third lemma_s

              _common( lemma_s ).singular_third_present
            end

            def _common lemma_s

              # it's tempting to try and stay within this node because it
              # feels like it's all here, but we need the lexicon attached
              # to the syntactic category so it's actually easier this way:

              POS__[]::Verb[ lemma_s ]
            end
          end  # >>

          Preterite = method :__preterite
          Progressive = method :__progressive
          Third = method :__third
        end

        class For_Verb  # (screen starting from here is example in #[#bs-028])

          class << self

            def via_lexeme__ lxm
              ___begin.__init_via_lexeme lxm
            end

            alias_method :___begin, :new
            undef_method :new
          end  # >>

          def initialize
            @_np = POS__[]::Noun[]  # build a noun phrase without a lexeme
          end

          def __init_via_lexeme lxm
            @_vp = POS__[]::Verb::Omni_Phrase.new @_np, lxm
            self
          end

          # --

          def preterite

            # (see note [#040] in the specs)

            @_vp << :preterite
            @_vp.to_string
          end

          def progressive

            # in the new edition, a verb *phrase* that is `progressive`
            # produces compound phrases like "is loving" instead of just
            # "loving". but clients need just the one word so:

            @_vp.lexeme.inflect_for_progressive_tense_( [] ) * SPACE_
          end

          def singular_third_present

            # [#037]:#the-axiom-of-non-redundant-state:#corollary-two

            @_np << :singular << :third
            @_vp.to_string
          end

          def plural_third_present  # ditto

            @_np << :plural << :third
            @_vp.to_string
          end

          def << sym
            _ = instance_variable_get DUPLICATED___.fetch sym
            _ << sym
            self
          end

          DUPLICATED___ = {
            first: :@_np,
            plural: :@_np,
            present: :@_vp,
            preterite: :@_vp,
            progressive: :@_vp,
            second: :@_np,
            singular: :@_np,
            third: :@_np,
          }

          def express_into y
            @_vp.express_into y
          end

          def lemma_symbol
            @_vp.lexeme.as_lemma_symbol_if_possible_
          end

          def lemma_string
            lxm = @_vp.lexeme
            if lxm.is_regular
              lxm.as_lemma_string_
            else
              lxm.lemma_x  # as long as it works?
            end
          end

          def lexeme
            @_vp.lexeme
          end

          module NOUN_PHRASE_SINGLETON___
            class << self
              def number
                NIL_
              end
              def person
                NIL_
              end
            end  # >>
          end
        end

        POS__ = -> do
          EN_::POS
        end
      end  # oneliner adapters
    end  # part of speech
  end  # en
end
