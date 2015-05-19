module Skylab::Human

    # (will rewrite)

    module NLP::EN::POS

      # this is strictly a cordoned-off box module only for parts of speech
      # modules. a parts of speech box module may only contain parts of
      # speech constants, or other parts of speech box modules.

      class << self

        attr_reader :_abbrev_box

        def abbrev h
          @_abbrev_box.merge! h ; nil
        end

        def indefinite_noun
          Indefinite_noun__
        end

        def plural_noun
          Plural_noun__
        end

        def preterite_verb
          Preterite_verb___
        end

        def progressive_verb
          Progressive_verb___
        end

        def third_person
          Third_person___
        end
      end  # >>
    end
end
