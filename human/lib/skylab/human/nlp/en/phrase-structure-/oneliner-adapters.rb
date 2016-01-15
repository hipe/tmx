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

        class For_Verb

          def initialize lexeme

            lib = POS__[]

            @_np = lib::Noun[]  # yes it's ok: a noun phrase without a lexeme

            @_vp = lib::Verb::Omni_Phrase.new @_np, lexeme
          end

          def lemma
            lxm = @_vp.lexeme
            if lxm.is_regular
              lxm.to_lemma_string
            else
              lxm.lemma_x  # as long as it works?
            end
          end

          def lexeme

            @_vp.lexeme
          end

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
