module Skylab::TanMan::TestSupport

  module Models::Node

    class << self

      def [] tcc
        TS_::Operations[ tcc ]
        tcc.include self
      end

      def __lib
        Home_::Models_::Node
      end
    end  # >>

    def with_operator_branch_for_nodes_

      _client = TS_::Models::Dot_File.PARSER_INSTANCE

      _path = digraph_file_path_

      _client.parse_file _path do |dc|

        @OB_FOR_NODES = Here__.__lib::NodesOperatorBranchFacade_.new dc
        x = yield
        remove_instance_variable :@OB_FOR_NODES
        x
      end
    end

    def touch_node_via_label label  # name preserved for legacy code for now
      @OB_FOR_NODES.touch_node_via_label___ label
    end

    def to_node_sexp_stream_
      @OB_FOR_NODES.__to_node_sexp_stream
    end

    def all_nodes_right_now_count_
      @OB_FOR_NODES.to_node_statement_stream___.flush_to_count
    end

    def stmt_list  # name preserved for legacy code for now
      @OB_FOR_NODES.instance_variable_get( :@_digraph_controller ).graph_sexp.stmt_list
    end

    define_method :fixtures_path_, ( Lazy_.call do
      ::File.join TS_.dir_path, 'fixture-dot-files-for-node'
    end )

    # ==

    Here__ = self

    # ==
    # ==
  end
end
# #history-A: full rewrite
