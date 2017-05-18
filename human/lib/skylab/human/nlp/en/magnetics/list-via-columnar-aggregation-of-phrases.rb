module Skylab::Human

  module NLP::EN

    class Magnetics::List_via_ColumnarAggregation_of_Phrases

      # implement [#052]. #cov1.4. use by [cm].
      # (referenced only by token `columnar_aggregation_of_phrases`)

      # (NOTE there is a same-named const above)

      # we are not sure how useful this will be outside of [cme] - here
      # it almost stands more as a proof of concept for its dependencies

      class << self

        def interpret_ scn
          scn.assert_empty
          new
        end
        private :new
      end  # >>

      def initialize

        @_bx = Common_::Box.new
      end

      # ~ mutation

      def add verb_sym, noun_sym
        @_bx.touch_array_and_push verb_sym, noun_sym
        NIL_
      end

      # ~ expression

      def express_into_line_context line_y

        @_POS = EN_::POS  # load it late

        @_zero = -> y do
          y << "(none)"
        end

        word_y = []

        pair_y = Home_::Sexp.expression_session_for(

          :list, :via, :eventing,

          :y, word_y,

          :iff_zero_items, @_zero,

          :any_first_item, -> y, x do
            _express_predicate y, x
          end,

          :any_subsequent_items, -> y, x do
            y << AND__
            _express_predicate y, x
          end,
        )

        @_bx.to_pair_stream.each do | pair |
          pair_y << pair
        end

        if word_y.length.zero?
          line_y
        else
          line_y << ( word_y * SPACE_ )
        end
      end

      def _express_predicate word_y, pair

        sym_y = Home_::Sexp.expression_session_for(

          :list, :via, :eventing,

          :y, word_y,

          :iff_zero_items, @_zero,

          :any_first_item, -> y, sym do

            __express_gerund y, sym, pair.name_symbol
          end,

          :any_subsequent_items, -> y, sym do

            y << AND__
            __express_additional_noun y, sym
          end,
        )

        pair.value.each do | sym |
          sym_y << sym
        end
        NIL_
      end

      def __express_gerund word_y, noun_sym, verb_sym

        # :delicious_coffee, :make  [..]->  "making", "delicious", "coffees"

        np = _noun_phrase_via_symbol noun_sym

        pn = @_POS::Pronoun.new_production

        vp = @_POS::Verb[ pn, _hack_lemma_via_symbol( verb_sym ) ]

        vp.object_noun_phrase = np

        vp.be_gerund = true

        vp << :progressive

        pn << :third << :singular

        vp.express_words_into word_y

        NIL_
      end

      def __express_additional_noun word_y, sym

        _np = _noun_phrase_via_symbol sym
        _np.express_words_into word_y
        NIL_
      end

      def _noun_phrase_via_symbol sym

        _n_lemma = _hack_lemma_via_symbol sym
        np = @_POS::Noun[ _n_lemma ]
        np << :plural
      end

      def _hack_lemma_via_symbol sym
        @_POS::Hack_lemma_via_symbol[ sym ]
      end

      AND__ = 'and'
    end
  end
end
