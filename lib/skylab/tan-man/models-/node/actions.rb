module Skylab::TanMan

  class Models_::Node  # is document entity

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

      Add = make_action_class :Create do

        edit_entity_class(
          :flag, :property, :ping,
          :reuse, Model_::Document_Entity.IO_properties )

      private

        def via_arguments_produce_bound_call
          if @argument_box[ :ping ]
            bound_call_for_ping
          else
            super
          end
        end
      end

      Ls = make_action_class :List do

        edit_entity_class(
          :reuse, Model_::Document_Entity.input_properties )
      end

      Rm = make_action_class :Delete do

        edit_entity_class(
          :reuse, Model_::Document_Entity.IO_properties )
      end
    end

    Silo__ = ::Class.new Model_::Document_Entity::Silo

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

      def receive_persist_entity action, entity
        _ok = mutate_via_verb_and_entity :create, entity
        _ok and _commit_changes action
      end

      def produce_relevant_sexp_via_touch_entity entity
        mutate_via_verb_and_entity :touch, entity
      end

      def via_datastore_controller_receive_delete_entity action, ent, & oes_p

        _ok = Node_::Actors__::Mutate::Via_entity.call(
          :delete,
          ent,
          @dsc,
          @kernel, & ( oes_p || @on_event_selectively ) )

        _ok and _commit_changes action
      end

      def mutate_via_verb_and_entity verb_i, entity
        _dsc = datastore_controller
        Node_::Actors__::Mutate::Via_entity.call(
          verb_i,
          entity,
          _dsc,
          @kernel, & @on_event_selectively )
      end

      def _entity_via_node node
        model_class.new( @kernel, & @on_event_selectively ).
          __init_via_node_stmt_and_immutable_preconditions node, @preconditions
      end

      def _commit_changes action
        datastore_controller.persist_via_args(
          @action.argument_box[ :dry_run ], * @action.output_arguments )
      end
    end

    def __init_via_node_stmt_and_immutable_preconditions node_stmt, precon_bx

      bx = Callback_::Box.new
      bx.add :name, node_stmt.label

      @preconditions = precon_bx
      @property_box = bx
      @node_stmt = node_stmt

      self
    end

    STOP_ = false
  end
end
