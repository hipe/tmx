module Skylab::TanMan

  class Models_::Meaning

    TanMan_::Entity_.call self,

        :persist_to, :meaning,

        :required,
        :ad_hoc_normalizer, -> arg, & oes_p do
          Meaning_::Actors__::Edit::Normalize_name[ arg, & oes_p ]
        end,
        :property, :name,

        :required,
        :ad_hoc_normalizer, -> arg, & oes_p do
          Meaning_::Actors__::Edit::Normalize_value[ arg, & oes_p ]
        end,
        :property, :value


    Actions__ = make_action_making_actions_module

    module Actions__

      Add = make_action_class :Create

      class Add

        edit_entity_class do
          o :required, :property, :input_string,
            :required, :property, :output_string
        end
      end

      Ls = make_action_class :List

      class Ls

        edit_entity_class do
          o :required, :property, :input_string
        end
      end

      Rm = make_action_class :Delete

    end

    class << self

      def collection_controller
        Meaning_::Collection_Controller__
      end
    end

    Meaning_ = self
    NAME_ = 'name'.freeze
    NEWLINE_ = "\n".freeze
    VALUE_ = 'value'.freeze

  end
end
