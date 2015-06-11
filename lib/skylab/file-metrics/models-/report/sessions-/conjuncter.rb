module Skylab::FileMetrics

  class Models_::Report

    class Sessions_::Conjuncter  # see [#010]

      def initialize

        @_bx = Callback_::Box.new
      end

      # ~ mutation

      def add verb_sym, noun_sym

        @_bx.touch verb_sym do
          []
        end.push noun_sym
        NIL_
      end

      # ~ expression

      def express_into_line_context line_y

        @_Articulators = Callback_::Scn.articulators  # load it late

        @_POS = FM_.lib_.human::NLP::EN::POS  # load it late

        @_zero = -> y do
          y << "(none)"
        end

        word_y = []

        pair_y = @_Articulators.eventing(

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

        sym_y = @_Articulators.eventing(

          :y, word_y,

          :iff_zero_items, @_zero,

          :any_first_item, -> y, sym do

            __express_gerund y, sym, pair.name_x
          end,

          :any_subsequent_items, -> y, sym do

            y << AND__
            __express_additional_noun y, sym
          end,
        )

        pair.value_x.each do | sym |
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

        s = sym.id2name
        s.gsub! UNDERSCORE_, SPACE_
        s
      end

      AND__ = 'and'
      UNDERSCORE_ = '_'
    end
  end
end
