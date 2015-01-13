module Skylab::TanMan

  class Models_::Node

    Entity_.call self,

        :persist_to, :node,

        :preconditions, [ :dot_file ],

        :required,
        :ad_hoc_normalizer, -> arg, & oes_p do
          Node_::Controller__::Normalize_name[ self, arg, & oes_p ]
        end,
        :property, :name


    Actions = make_action_making_actions_module

    module Actions

      Add = make_action_class :Create

      class Add

        Model_::Entity.call self,

          :reuse, Model_::Document_Entity.IO_properties,

          :flag, :property, :ping

      private

        def via_arguments_produce_bound_call
          if @argument_box[ :ping ]
            bound_call_for_ping
          else
            _bc = resolve_document_IO_or_produce_bound_call_
            _bc or super
          end
        end
      end

      Ls = make_action_class :List

      class Ls

        Model_::Entity.call self,

          :reuse, Model_::Document_Entity.input_properties

        def via_arguments_produce_bound_call
          _bc = resolve_document_IO_or_produce_bound_call_
          _bc or super
        end
      end

      Rm = make_action_class :Delete

      class Rm

        Model_::Entity.call self,

          :reuse, Model_::Document_Entity.input_properties

        def via_arguments_produce_bound_call
          _bc = resolve_document_IO_or_produce_bound_call_
          _bc or super
        end
      end
    end

    class Collection_Controller__ < Model_::Document_Entity::Collection_Controller

      def entity_stream_via_model model
        if model_class == model
          to_node_stream.map_by do | node |
            _entity_via_node node
          end
        end
      end

      def entity_via_identifier node_identifier, & oes_p

        label_s = node_identifier.entity_name_s

        node = to_node_stream.detect do | node_ |
          label_s == node_.label
        end

        if node

          _entity_via_node node

        elsif oes_p
          oes_p.call :info, :entity_not_found do
            Callback_::Event.inline_neutral_with :entity_not_found,
              :entity_name_string, node_identifier.entity_name_s
          end
        end
      end

      def retrieve_any_node_with_id i
        to_node_stream.detect do |node|
          i == node.node_id
        end
      end

      def to_node_stream
        datastore_controller.at_graph_sexp :nodes
      end

      def get_node_statement_scan
        datastore_controller.at_graph_sexp :node_statements
      end

      def at_graph_sexp i
        datastore_controller.at_graph_sexp i
      end

      def touch_node_via_label s

        node = Node_.edit_entity @kernel, handle_event_selectively do |o|
          o.edit_with :name, s
        end

        node and begin
          produce_relevant_sexp_via_touch_entity node
        end
      end

      def persist_entity entity
        _ok = mutate_via_verb_and_entity :create, entity
        _ok and _commit_changes_to_dsc datastore_controller
      end

      def produce_relevant_sexp_via_touch_entity entity
        mutate_via_verb_and_entity :touch, entity
      end

      def via_dsc_delete_entity ent, & oes_p

        _ok = Node_::Actors__::Mutate::Via_entity[
          :delete,
          ent,
          @dsc,
          @kernel, ( oes_p || @on_event_selectively ) ]

        _ok and _commit_changes_to_dsc @dsc
      end

      def mutate_via_verb_and_entity verb_i, entity
        _dsc = datastore_controller
        Node_::Actors__::Mutate::Via_entity[
          verb_i,
          entity,
          _dsc,
          @kernel, @on_event_selectively ]
      end

      def _entity_via_node node
        model_class.new( @kernel, & @on_event_selectively ).init_via_node node
      end

      def _commit_changes_to_dsc dsc
        dsc.persist_via_args(
          @action.any_argument_value( :dry_run ), * @action.output_arguments )
      end
    end

    def init_via_node node

      bx = @property_box = Callback_::Box.new
      bx.add :name, node.label
      self
    end

    STOP_ = false
  end
end
