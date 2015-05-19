module Skylab::Human

  module NLP::EN

    module POS  # intro at [#037]. three laws all the way.

      # this is strictly a cordoned-off box module only for parts of speech
      # modules. a parts of speech box module may only contain parts of
      # speech constants, or other parts of speech box modules.

      class << self

        def indefinite_noun lemma_s
          _lib::Noun::Indefinite[ lemma_s ]
        end

        def plural_noun count_d=nil, lemma_s
          _lib::Noun::Plural[ count_d, lemma_s ]
        end

        def preterite_verb lemma_s
          _lib::Verb::Preterite[ lemma_s ]
        end

        def progressive_verb lemma_s
          _lib::Verb::Progressive[ lemma_s ]
        end

        def third_person lemma_s
          _lib::Verb::Third[ lemma_s ]
        end

        def _lib
          EN_::Phrase_Structure_::Oneliner_Adapters
        end
      end  # >>

      Autoloader_[ self ]
    end
  end
end
