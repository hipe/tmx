module Skylab::Human

  NLP.const_get :Expression_Frame

  class NLP::Expression_Frame

    NLP::EN.const_get :Idiomization_

    module NLP::EN::Idiomization_

      class NLP::EN::Expression_Frames___::Count_and_Noun < EF_

        REQUIRED_TERMS = [ :subject_atom, :subject_integer ]

        OPTIONAL_TERMS = nil

        PRODUCES = [ :noun_phrase ]

        def initialize idea

          d = idea.subject_integer.to_integer

          np = EN_::POS::Noun[ idea.subject_atom.to_string ]

          np.initialize_adjective_phrase(
            EN_::Phrase_Structure::Noun_inflectee_via_string[ d.to_s ] )

          @noun_phrase = case 1 <=> d.abs
          when 1

            if d.zero?
              np << :plural
            end

          when 0
            np << :_do_not_use_article_
            np << :singular

          when -1
            np << :plural
          end
        end

        def express_into upstream_x  # :+#cp

          _y = @noun_phrase.express_words_into []

          _s = to_string_with_punctuation_hack_ _y

          upstream_x << _s
        end

        attr_reader :noun_phrase
      end
    end
  end
end
