require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Node

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  EMPTY_S_ = TestLib_::EMPTY_S_
  NEWLINE_ = TestLib_::NEWLINE_
  Home_ = Home_

  module InstanceMethods

    def stmt_list
      _node_collection_controller.at_graph_sexp :stmt_list
    end

    def number_of_nodes
      get_node_statement_scan.count
    end

    def retrieve_any_node_with_id i
      _node_collection_controller.retrieve_any_node_with_id i
    end

    def get_node_statement_scan
      _node_collection_controller.get_node_statement_scan
    end

    def get_node_array
      node_sexp_stream.to_a
    end

    def node_sexp_stream
      _node_collection_controller.to_node_sexp_stream
    end

    def touch_node_via_label s
      _node_collection_controller.touch_node_via_label s
    end

    def unparsed
      s = ''
      _node_collection_controller.unparse_into s
      s
    end

    def module_with_subject_fixtures_node
      TS_
    end

    def subject_model_name_i
      :node
    end

    def _node_collection_controller
      @___ncc ||= __build_node_collection_controller
    end

    def __build_node_collection_controller

      # TL;DR: a messy dance to give a document controller to the topic c.c.

      # problematically (and years ago) we thought we wanted to test what is
      # now this silo's hand-made collection controller as a "unit" divorced
      # from the functional layer. but this c.c uses preconditions that come
      # from formal preconds and formal preconds come from the action. so we
      # need to know the action anyway to build the c.c. (the fact that this
      # component has "controller" in the name is a hint that it should only
      # be tested functionally. food for the thoughts of the future.)

      # because we don't want any of the above knowledge to be built deeply
      # into out tests, we just hack-build an actual preconditions box here
      # manually until the four or so tests that need this can be improved.

      kr = Home_.application_kernel_

      silo = kr.silo :node

      id = silo.silo_module.node_identifier

      oes_p = handle_event_selectively

      action = Mock_Action___.new(
        send( :"__via__#{ input_mechanism_i }__build_byte_upstream_identifier" ),
        kr, & oes_p )

      bx = Home_::Callback_::Box.new
      bx.add :dot_file,
        kr.silo( :dot_file ).precondition_for( action, id, :_no_box_, & oes_p )

      silo.precondition_for_self action, id, bx, & oes_p
    end

    def __via__input_file_granule__build_byte_upstream_identifier

      Home_::Brazen_.byte_upstream_identifier.via_path input_file_path

    end
  end

  H__ = {
    input_path: :path
  }

  class Mock_Action___

    def initialize up_id, k, & oes_p
      @document_entity_byte_upstream_identifier = up_id
      @kernel = k
      @oes_p = oes_p
    end

    attr_reader(
      :document_entity_byte_upstream_identifier,
      :kernel,
    )

    def handle_event_selectively
      @oes_p
    end
  end
end
