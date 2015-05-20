module Skylab::Human

  module NLP::EN::Idiomization_

    class Models::Portable_List_Phrase

      def initialize list_arg

        @_list_arg = list_arg
      end

      def inflect_words_into_against_sentence_phrase y, _
        y << ':'
        inflect_words_into_against_noun_phrase y, nil
      end

      def inflect_words_into_against_noun_phrase y, _

        Callback_::Oxford_comma_into[ y, @_list_arg.to_array, 'and', ',' ]
      end
    end
  end
end
