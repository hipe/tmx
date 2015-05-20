module Skylab::Human

  NLP::EN.const_get :Phrase_Structure_, false

  module NLP::EN::Phrase_Structure_

    class NLP::EN::POS::Sentence < Models::Syntactic_Category

      class << self

        def [] np, vp
          self::Omni_Phrase.new np, vp
        end
      end  # >>

      class Omni_Phrase < Omni_Phrase

        ORDER = [ :noun_phrase, :verb_phrase, :conjunctive_tail_ ]

        def initialize np, vp
          @noun_phrase = np
          @verb_phrase = vp
          super nil
        end

        def inflect_child_production_ y, phrase

          phrase.inflect_words_into_against_sentence_phrase y, self
        end

        # ~ in order

        attr_reader :noun_phrase, :verb_phrase

        attr_accessor :conjunctive_tail_  # hac't for now

        def << exponent_symbol
          self._FUN
        end
      end
    end
  end
end
