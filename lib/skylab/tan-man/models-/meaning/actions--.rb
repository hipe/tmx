module Skylab::TanMan

  class Models_::Meaning

    TanMan_::Entity_.call self,

        :persist_to, :meaning,

        :preconditions, [ :dot_file ],

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

      Add = make_action_class :Create do

        edit_entity_class(
          :flag, :property, :force,
          :reuse, Model_::Document_Entity.IO_properties )

        def via_arguments_produce_bound_call
          resolve_document_IO_or_produce_bound_call_ or super
        end
      end

      Ls = make_action_class :List do

        edit_entity_class :reuse, Model_::Document_Entity.IO_properties

        def via_arguments_produce_bound_call
          resolve_document_upstream_or_produce_bound_call_ or super
        end
      end

      Rm = make_action_class :Delete

    end

    class << self

      def collection_controller_class
        Meaning_::Collection_Controller__
      end
    end

    Meaning_ = self
    NAME_ = 'name'.freeze
    NEWLINE_ = "\n".freeze
    VALUE_ = 'value'.freeze

  end
end
