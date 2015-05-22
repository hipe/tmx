module Skylab::Human

  module NLP::EN::Idiomization_

    class Models::Portable_List_Phrase

      # this is at its essence a phrase adapter for the oxford comma function

      class << self

        def new_via_array a

          new_via_list_arg NLP::Expression_Frame.list_argument_via_array a
        end

        alias_method :new_via_list_arg, :new
        private :new
      end  # >>

      def initialize list_arg

        @final_separator = DEFAULT_FINAL_SEPARATOR___
        @item_map = nil
        @_list_arg = list_arg
        @non_final_separator = DEFAULT_NON_FINAL_SEPARATOR___
      end

      DEFAULT_FINAL_SEPARATOR___ = 'and'
      DEFAULT_NON_FINAL_SEPARATOR___ = ','

      attr_writer :final_separator,
        :inflect_words_into_against_noun_phrase_under,
        :item_map,
        :non_final_separator


      def express_words_into_under y, expag

        @inflect_words_into_against_noun_phrase_under[ y, :_none_, expag, self ]
      end

      def inflect_words_into_against_sentence_phrase y, _

        y << ':'
        inflect_words_into_against_noun_phrase y, nil
      end

      def inflect_words_into_against_noun_phrase y, _

        x_a = @_list_arg.to_array
        if @item_map
          x_a = x_a.map( & @item_map )
        end

        Callback_::Oxford_comma_into.call(
          y,
          x_a,
          @final_separator,
          @non_final_separator )
      end
    end
  end
end
