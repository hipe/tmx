module Skylab::Snag

  class Models_::Node

    Expression_Adapters::EN = -> da do

      _id_int = da.module::Association_Adapter.new_with(

        :verb_lemma_and_phrase_head_s_a,
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
            :non_negative_integer ] )

      da.under_target_model_add_association_adapter :ID_Int, _id_int

      da.source_and_target_models_are_associated :Node, :ID_Int

      NIL_
    end
  end
end
