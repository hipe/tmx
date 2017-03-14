module Skylab::Snag

  class Models_::Node

    ExpressionAdapters::EN = -> da do

      da.under_target_model_add_association_adapter :Ext_Cnt, (
        da.module::Association_Adapter.with(

          :verb_lemma, 'have',

          :named_functions,

            :yes_or_no, :sequence, [
              :zero_or_one, :keyword, 'no',
              :keywords, %w( extended content ) ] ) )


      da.source_and_target_models_are_associated :Node, :Ext_Cnt

      da.under_target_model_add_association_adapter :ID_Int, (
        da.module::Association_Adapter.with(

          :verb_lemma_and_phrase_head_string_array,
            %w( have an identifier with an integer ),

          :named_functions,

            :greater_than_or_equal_to, :sequence, [
              :keywords, %w( greater than or equal to ),
              :non_negative_integer ],

            :greater_than, :sequence, [
              :keywords, %w( greater than ),
              :non_negative_integer ],

            :less_than_or_equal_to, :sequence, [
              :keywords, %w( less than or equal to ),
              :non_negative_integer ],

            :less_than, :sequence, [
              :keywords, %w( less than ),
              :non_negative_integer ] ) )

      da.source_and_target_models_are_associated :Node, :ID_Int

      rx = /\A#{ Home_::Models::Hashtag::RX_STRING }\z/

      # ~ begin at the crux of [#005]: to meet the spec, below we currently
      #     require two assoc adapters, and would rather model only one
      #     more expressive adapter. but to get it right requires ideal
      #     support for modeling joints breakability for (separately) the
      #     boolean conjunctives and the negation operator.

      da.under_target_model_add_association_adapter :Tags, (

        da.module::Association_Adapter.with(

          :verb_lemma_and_phrase_head_string_array, %w( be tagged with ),

          :named_functions,
            :positive_tag, :regex, rx ) )

      da.under_target_model_add_association_adapter :Tags, (

        da.module::Association_Adapter.with(

          :verb_lemma_and_phrase_head_string_array, %w( be not tagged with ),

          :named_functions,
            :negative_tag, :regex, rx ) )

      # ~ end

      da.source_and_target_models_are_associated :Node, :Tags

      NIL_
    end
  end
end
