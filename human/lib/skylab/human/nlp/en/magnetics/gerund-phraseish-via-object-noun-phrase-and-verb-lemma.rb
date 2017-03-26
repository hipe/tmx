module Skylab::Human

  module NLP::EN

    class Magnetics::GerundPhraseish_via_ObjectNounPhrase_and_VerbLemma <
        Magnetics::NounPhraseish_via_Components::AbstractBase_REDUX

      # referenced by `gerund_phraseish` 1x [fi], Nx [here]

      # referenced by name 1x, [here] only.

      class << self
        alias_method :interpret_component_fully_, :new
        private :new
      end  # >>

      COMPONENTS = Attributes_[
        object_noun_phrase: :component,
        verb_lemma: :_atomic_,
      ]

      attr_reader( * COMPONENTS.symbols )

      def initialize scn, asc

        _ok = COMPONENTS.init_via_argument_scanner self, scn
        _ok or fail
        super asc
      end

      def __object_noun_phrase__component_association
        Magnetics::NounPhraseish_via_Components
      end

      def express_into_under y, expag

        _hi = EN_::POS::Verb[ @verb_lemma.id2name ].progressive
        y << "#{ _hi }#{ SPACE_ }"
        @object_noun_phrase.express_into_under y, expag
      end

      def assimilate_with_same_type_ exp
        Magnetics::List_via_TreeishAggregation_of_Phrases::Assimilate[ self, exp ]
      end

      def _can_aggregate_
        true
      end

      def category_symbol_
        :gerund_phraseish
      end
    end
  end
end
