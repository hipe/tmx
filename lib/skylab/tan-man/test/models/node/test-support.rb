require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Node

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  EMPTY_S_ = TestLib_::EMPTY_S_
  NEWLINE_ = TestLib_::NEWLINE_

  module InstanceMethods

    Constants::Within_silo[ :node, self ]

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
      node_sexp_stream.to_a
    end

    def node_sexp_stream
      collection_controller.to_node_sexp_stream
    end

    def touch_node_via_label s
      collection_controller.touch_node_via_label s
    end

    def unparsed
      collection_controller.unparse_into ""
    end

    def module_with_subject_fixtures_node
      TS_
    end

    def subject_model_name_i
      :node
    end
  end
end
