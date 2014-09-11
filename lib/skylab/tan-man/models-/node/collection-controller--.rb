module Skylab::TanMan

  class Models_::Node

    class Collection_Controller__ < Model_::Document_Entity::Collection_Controller

      def retrieve_any_node_with_id i
        get_node_scan.detect do |node|
          i == node.node_id
        end
      end

      def get_node_scan
        @datastore_controller.at_graph_sexp :nodes
      end

      def get_node_statement_scan
        @datastore_controller.at_graph_sexp :node_statements
      end

      def at_graph_sexp i
        @datastore_controller.at_graph_sexp i
      end

      def touch_node_via_label s
        node = Node_.for_edit @channel, @delegate, @kernel do |o|
          o.with :name, s
        end
        if node.error_count.zero?
          produce_relevant_sexp_via_touch_entity node
        end
      end

      def persist_entity entity
        ok = mutate_via_verb_and_entity :create, entity
        ok and maybe_persist
      end

      def produce_relevant_sexp_via_touch_entity entity
        mutate_via_verb_and_entity :touch, entity
      end

      def mutate_via_verb_and_entity verb_i, entity
        self.class::Mutate::Via_entity[
          verb_i, entity,
          @datastore_controller,
          @channel, @delegate, @kernel ]
      end
    end
  end
end
