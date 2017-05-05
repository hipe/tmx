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

    def to_one_array__symbols_
      sym_a = []

      to_node_sexp_stream_.each do |node_stmt|
        sym_a.push node_stmt.node_ID_symbol_  # (yes, you could map instead)
      end

      sym_a
    end

    def to_two_arrays__labels_and_symbols_
      s_a = [] ; sym_a = []

      to_node_sexp_stream_.each do |node_stmt|
        sym_a.push node_stmt.node_ID_symbol_
        s_a.push node_stmt.get_label_
      end

      [ s_a, sym_a ]
    end

    def with_operator_branch_for_nodes_  # (has counterpart in assoc)

      _client = TS_::Models::Dot_File.PARSER_INSTANCE

      _path = digraph_file_path_

      _client.parse_file _path do |dc|

        @OB_FOR_NODES = Here__.__lib::NodesOperatorBranchFacade_TM.new dc
        x = yield
        remove_instance_variable :@OB_FOR_NODES
        x
      end
    end

    def touch_node_via_label label, & p  # name preserved for legacy code for now
      @OB_FOR_NODES.touch_node_via_label_ label, & p
    end

    def to_node_sexp_stream_
      @OB_FOR_NODES.__to_node_sexp_stream
    end

    def all_nodes_right_now_count_
      @OB_FOR_NODES.to_node_statement_stream___.flush_to_count
    end

    def stmt_list  # name preserved for legacy code for now
      graph_sexp_.stmt_list
    end

    def graph_sexp_
      @OB_FOR_NODES.instance_variable_get( :@_digraph_controller ).graph_sexp
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
