require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Node

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include CONSTANTS

  NEWLINE_ = "\n".freeze  # etc

  extend TestSupport_::Quickie

  module InstanceMethods

    CONSTANTS::Within_silo[ :node, self ]

    def stmt_list
      collection_controller.at_graph_sexp :stmt_list
    end

    def number_of_nodes
      get_node_statement_scan.count
    end

    def retrieve_any_node_with_id i
      collection_controller.retrieve_any_node_with_id i
    end

    def get_node_statement_scan
      collection_controller.get_node_statement_scan
    end

    def get_node_array
      get_node_scan.to_a
    end

    def get_node_scan
      collection_controller.get_node_scan
    end

    def touch_node_via_label s
      collection_controller.touch_node_via_label s
    end

    def unparsed
      collection_controller.unparse_entire_document
    end

    def module_with_subject_fixtures_node
      TS_
    end

    def subject_model_name_i
      :node
    end
  end
end
