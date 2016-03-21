module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::Gerund_Phraseish < Expression_Sessions::Nounish::Redux_Abstract_Base  # ..

      class << self
        alias_method :interpret_component_with_own_stream_, :new
        private :new
      end  # >>

      COMPONENTS = Attributes_[
        object_noun_phrase: :component,
        verb_lemma: :_atomic_,
      ]

      attr_reader( * COMPONENTS.symbols )

      def initialize st, asc

        o = COMPONENTS.begin_parse_and_normalize_for self
        o.argument_stream = st
        _ok = o.execute
        _ok and super asc
      end

      def __object_noun_phrase__component_association
        Siblings_::Nounish
      end

      def express_into_under y, expag

        _hi = EN_::POS::Verb[ @verb_lemma.id2name ].progressive
        y << "#{ _hi }#{ SPACE_ }"
        @object_noun_phrase.express_into_under y, expag
      end

      def assimilate_with_same_type_ exp
        Siblings_::List_through_Treeish_Aggregation::Assimilate[ self, exp ]
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
