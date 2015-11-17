module Skylab::TanMan

  class Models_::Meaning  # re-opening

    edit_entity_class(

      :persist_to, :meaning,

      :preconditions, [ :dot_file ],

      :required,
      :ad_hoc_normalizer, -> qkn, & oes_p do
        Meaning_::Actors__::Edit::Normalize_name[ qkn, & oes_p ]
      end,
      :property, :name,

      :required,
      :ad_hoc_normalizer, -> qkn, & oes_p do
        Meaning_::Actors__::Edit::Normalize_value[ qkn, & oes_p ]
      end,
      :property, :value )

    Actions__ = make_action_making_actions_module

    module Actions__

      Add = make_action_class :Create do

        edit_entity_class(
          :flag, :property, :force,
          :reuse, Model_::Document_Entity.IO_properties )

      end

      Ls = make_action_class :List do

        edit_entity_class :reuse, Model_::Document_Entity.input_properties

      end

      Rm = make_action_class :Delete

      class Associate < Home_::Model_::Document_Entity::Action

        Entity_.call self,

          :desc, -> y do
            y << "apply a meaningful tag to a node"
          end,

          :preconditions, [ :dot_file, :meaning, :node ],

          :reuse, Home_::Model_::Document_Entity.IO_properties,
          :flag, :property, :dry_run,
          :required, :property, :meaning_name,
          :required, :property, :node_label

        def produce_result
          @meanings_controller = @preconditions.fetch :meaning
          @nodes_controller = @preconditions.fetch :node
          ok = __resolve_meaning
          ok &&= __resolve_node
          ok &&= __apply_meaning_to_node
          ok && __persist
        end

        def __resolve_meaning
          @meaning = @meanings_controller.one_entity_against_natural_key_fuzzily_ @argument_box[ :meaning_name ]
          @meaning and ACHIEVED_
        end

        def __resolve_node
          @node = @nodes_controller.one_entity_against_natural_key_fuzzily_ @argument_box[ :node_label ]
          @node and ACHIEVED_
        end

        def __apply_meaning_to_node
          @meanings_controller.apply_meaning_to_node @meaning, @node
        end

        def __persist

          @preconditions.fetch( :meaning ).
            flush_changed_document_to_output_adapter_per_action self
        end
      end
    end

    class Silo_Daemon < Silo_daemon_base_class_[]

      def precondition_for_self action, id, box, & oes_p
        Meaning_::Collection_Controller__.new action, box, @silo_module, @kernel, & oes_p
      end
    end

    Meaning_ = self
    NAME_ = 'name'.freeze
    NEWLINE_ = "\n".freeze
    VALUE_ = 'value'.freeze

  end
end
