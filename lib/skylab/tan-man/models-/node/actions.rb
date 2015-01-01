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
            bc = any_bound_call_for_resolve_document_IO
            bc or super
          end
        end
      end

      Ls = make_action_class :List

      class Ls

        Model_::Entity.call self,

            :reuse, Model_::Document_Entity.input_properties
      end

      Rm = make_action_class :Delete

    end

    class Collection_Controller__ < Model_::Document_Entity::Collection_Controller

      def retrieve_any_node_with_id i
        get_node_scan.detect do |node|
          i == node.node_id
        end
      end

      def get_node_scan
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
          o.where :name, s
        end

        node and begin
          produce_relevant_sexp_via_touch_entity node
        end
      end

      def persist_entity entity
        ok = mutate_via_verb_and_entity :create, entity
        ok and datastore_controller.persist_via_args( *
          @action.output_related_arguments )
      end

      def produce_relevant_sexp_via_touch_entity entity
        mutate_via_verb_and_entity :touch, entity
      end

      def mutate_via_verb_and_entity verb_i, entity
        _dsc = datastore_controller
        Node_::Actors__::Mutate::Via_entity[
          verb_i,
          entity,
          _dsc,
          @kernel, @on_event_selectively ]
      end
    end

    STOP_ = false
  end

  if false

  class API::Actions::Graph::Node::Add < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :dry_run, :force, :name, :verbose ]

  private

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        node = cnt.add_node name, dry_run, force, verbose,
          -> e do # error
            send_error_mixed e.to_h
          end,
          -> e do # success
            send_info_mixed e.to_h
          end
       if node
         res = cnt.write dry_run, force, verbose
       else
         res = false
       end
       res
      end while nil
      res
    end
  end

  class API::Actions::Graph::Node::List < API::Action

    extend API::Action::Parameter_Adapter

    PARAMS = [ :verbose ]

  private

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        count = 0
        cnt.list_nodes verbose, -> node_stmt do
          count += 1
          send_payload_string "#{ lbl node_stmt.label }"
        end
        send_info_string "(#{ count } total)"
      end while nil
      res
    end
  end

  class API::Actions::Graph::Node::Rm < API::Action

    extend API::Action::Parameter_Adapter

    PARAMS = [ :dry_run, :node_ref, :verbose ]

  private

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        destroyed = cnt.rm_node node_ref,
          true, # always fuzzy for now
          -> e do
            send_error_mixed e.to_h
            res = false
          end,
          -> e do
            send_info_mixed e.to_h
            e # we gotta, it becomes `destroyed`
          end
        if destroyed
          res = cnt.write dry_run, true, verbose # always force here
        end
      end while nil
      res
    end
  end
  end
end
